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
        apiResponse.error = 'Not authenticated';
        return apiResponse;
      }

      final requestBody = {
        'schedule_id': scheduleId,
        'seat_number': seatNumber,
        'status': 'pending',
        'total_price': totalPrice,
      };

      print('Request body: $requestBody'); // Debug print

      final response = await http.post(
        Uri.parse('$baseURL/bookings'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      switch (response.statusCode) {
        case 201:
          apiResponse.data = Booking.fromJson(jsonDecode(response.body));
          break;
        case 401:
          apiResponse.error = 'Unauthorized';
          break;
        case 422:
          final responseData = jsonDecode(response.body);
          if (responseData['errors'] != null) {
            final firstError = responseData['errors'].values.first;
            apiResponse.error =
                firstError is List ? firstError.first : firstError.toString();
          } else if (responseData['message'] != null) {
            apiResponse.error = responseData['message'];
          } else {
            apiResponse.error = 'Validation error';
          }
          break;
        default:
          final responseData = jsonDecode(response.body);
          apiResponse.error =
              responseData['message'] ?? 'Failed to create booking';
          break;
      }
    } catch (e) {
      print('Error creating booking: $e');
      apiResponse.error = 'Server error: $e';
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

  Future<ApiResponse> cancelBooking(int bookingId) async {
    return updateBookingStatus(bookingId, 'canceled');
  }
}
