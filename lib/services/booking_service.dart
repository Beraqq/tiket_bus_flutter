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
      print('=== Creating Booking ===');
      print('Schedule ID: $scheduleId');
      print('Seat Number: $seatNumber');
      print('Total Price: $totalPrice');

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Sesi telah berakhir. Silakan login kembali.');
      }

      final response = await http.post(
        Uri.parse(bookingURL),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'schedule_id': scheduleId,
          'seat_number': seatNumber,
          'status': 'pending'
        }),
      );

      print('Create Booking URL: $bookingURL');
      print('Request Body: ${jsonEncode({
            'schedule_id': scheduleId,
            'seat_number': seatNumber,
            'status': 'pending'
          })}');
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (responseData['status'] == 'success') {
          final bookingData = responseData['data']['booking'];
          apiResponse.data = Booking.fromJson(bookingData);
          print('Booking created successfully');
        } else {
          throw Exception(responseData['message'] ?? 'Gagal membuat pemesanan');
        }
      } else {
        throw Exception(responseData['message'] ?? 'Gagal membuat pemesanan');
      }
    } catch (e) {
      print('Exception in createBooking: $e');
      apiResponse.error = e.toString().replaceAll('Exception: ', '');
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
        apiResponse.error = 'Sesi telah berakhir. Silakan login kembali.';
        return apiResponse;
      }

      final response = await http.put(
        Uri.parse('$bookingURL/$bookingId'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': 'canceled'}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          apiResponse.data = true;
        } else {
          apiResponse.error = responseData['message'];
        }
      } else {
        final responseData = jsonDecode(response.body);
        apiResponse.error =
            responseData['message'] ?? 'Gagal membatalkan pemesanan';
      }
    } catch (e) {
      print('Exception in cancelBooking: $e');
      apiResponse.error = 'Gagal terhubung ke server';
    }
    return apiResponse;
  }

  Future<ApiResponse> checkSeatAvailability(
      String scheduleId, int seatNumber) async {
    ApiResponse apiResponse = ApiResponse();
    try {
      print('=== Checking Seat Availability ===');
      print('Schedule ID: $scheduleId');
      print('Seat Number: $seatNumber');

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('Token not found');
        apiResponse.error = 'Sesi telah berakhir. Silakan login kembali.';
        return apiResponse;
      }

      final url = '$bookingURL/check-availability/$scheduleId';
      print('Checking availability at: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['available_seats'] != null) {
          final availableSeats =
              List<int>.from(responseData['available_seats']);
          apiResponse.data = availableSeats.contains(seatNumber);
          print('Available seats: $availableSeats');
          print('Requested seat $seatNumber is available: ${apiResponse.data}');
        } else {
          throw Exception('Format response tidak valid');
        }
      } else {
        final responseData = jsonDecode(response.body);
        throw Exception(
            responseData['message'] ?? 'Gagal memeriksa ketersediaan kursi');
      }
    } catch (e) {
      print('Exception in checkSeatAvailability: $e');
      apiResponse.error = 'Gagal memeriksa ketersediaan kursi';
    }
    return apiResponse;
  }
}
