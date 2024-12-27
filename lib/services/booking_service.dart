import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiketBus/constant.dart';
import '../models/api_response.dart';
import '../models/booking.dart';

class BookingService {
  Future<ApiResponse> createBooking({
    required String scheduleId,
    required int seatNumber,
    required double totalPrice,
  }) async {
    ApiResponse apiResponse = ApiResponse();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        apiResponse.error = unauthorized;
        return apiResponse;
      }

      final response = await http.post(
        Uri.parse('$bookingURL/create'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'schedule_id': scheduleId,
          'seat_number': seatNumber,
          'total_price': totalPrice,
          'status': 'pending',
          'payment_deadline':
              DateTime.now().add(const Duration(minutes: 15)).toIso8601String(),
        }),
      );

      switch (response.statusCode) {
        case 200:
          apiResponse.data = Booking.fromJson(jsonDecode(response.body));
          break;
        case 401:
          apiResponse.error = unauthorized;
          break;
        default:
          apiResponse.error = somethingWentWrong;
          break;
      }
    } catch (e) {
      apiResponse.error = serverError;
    }
    return apiResponse;
  }

  Future<ApiResponse> getBookings() async {
    ApiResponse apiResponse = ApiResponse();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        apiResponse.error = 'Not authenticated';
        return apiResponse;
      }

      final response = await http.get(
        Uri.parse('baseURL/bookings'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      switch (response.statusCode) {
        case 200:
          List<dynamic> data = jsonDecode(response.body);
          apiResponse.data = data.map((p) => Booking.fromJson(p)).toList();
          break;
        case 401:
          apiResponse.error = 'Unauthorized';
          break;
        default:
          apiResponse.error = 'Failed to load bookings';
          break;
      }
    } catch (e) {
      apiResponse.error = 'Server error: $e';
    }
    return apiResponse;
  }

  Future<ApiResponse> updateBookingStatus(int bookingId, String status) async {
    ApiResponse apiResponse = ApiResponse();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        apiResponse.error = 'Not authenticated';
        return apiResponse;
      }

      final response = await http.put(
        Uri.parse('baseURL/bookings/$bookingId/status'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'status': status,
        }),
      );

      switch (response.statusCode) {
        case 200:
          apiResponse.data = Booking.fromJson(jsonDecode(response.body));
          break;
        case 401:
          apiResponse.error = 'Unauthorized';
          break;
        case 404:
          apiResponse.error = 'Booking not found';
          break;
        default:
          apiResponse.error = 'Failed to update booking status';
          break;
      }
    } catch (e) {
      apiResponse.error = 'Server error: $e';
    }
    return apiResponse;
  }

  Future<ApiResponse> cancelBooking(String bookingId) async {
    ApiResponse apiResponse = ApiResponse();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        apiResponse.error = unauthorized;
        return apiResponse;
      }

      final response = await http.post(
        Uri.parse('$bookingURL/cancel/$bookingId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      switch (response.statusCode) {
        case 200:
          apiResponse.data = true;
          break;
        case 401:
          apiResponse.error = unauthorized;
          break;
        default:
          apiResponse.error = somethingWentWrong;
          break;
      }
    } catch (e) {
      apiResponse.error = serverError;
    }
    return apiResponse;
  }
}
