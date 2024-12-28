import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiketBus/constant.dart';
import '../models/api_response.dart';
import '../models/booking.dart';
import 'user_service.dart';

class BookingService {
  Future<ApiResponse> createBooking({
    required String scheduleId,
    required int seatNumber,
    required double totalPrice,
  }) async {
    ApiResponse apiResponse = ApiResponse();

    try {
      print('=== Starting Booking Process ===');
      print('Schedule ID: $scheduleId');
      print('Seat Number: $seatNumber');
      print('Total Price: $totalPrice');

      String token = await getToken();

      final response = await http.post(
        Uri.parse('$baseURL/bookings'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({
          'schedule_id': scheduleId,
          'seat_number': seatNumber.toString(),
          'total_price': totalPrice,
          'status': 'pending',
          'payment_status': 'unpaid',
        }),
      );

      print('Booking Response Status: ${response.statusCode}');
      print('Booking Response Body: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          final bookingData = responseData['data']['booking'];
          apiResponse.data = Booking.fromJson(bookingData);
        } else {
          throw Exception(responseData['message'] ?? 'Booking failed');
        }
      } else {
        final responseBody = jsonDecode(response.body);
        throw Exception(responseBody['message'] ?? 'Booking failed');
      }
    } catch (e) {
      print('Error creating booking: $e');
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

  Future<ApiResponse> getBookingDetails(String bookingId) async {
    ApiResponse apiResponse = ApiResponse();

    try {
      String token = await getToken();
      final response = await http.get(
        Uri.parse('$baseURL/bookings/$bookingId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      print('Booking Details Response Status: ${response.statusCode}');
      print('Booking Details Response Body: ${response.body}');

      switch (response.statusCode) {
        case 200:
          final responseData = jsonDecode(response.body);
          if (responseData['status'] == 'success') {
            apiResponse.data = Booking.fromJson(responseData['data']);
          } else {
            throw Exception(
                responseData['message'] ?? 'Gagal memuat detail booking');
          }
          break;
        case 401:
          apiResponse.error = 'Sesi telah berakhir. Silakan login kembali';
          break;
        case 404:
          apiResponse.error = 'Booking tidak ditemukan';
          break;
        default:
          apiResponse.error = 'Terjadi kesalahan. Silakan coba lagi';
          break;
      }
    } catch (e) {
      print('Error getting booking details: $e');
      apiResponse.error = 'Terjadi kesalahan pada server';
    }

    return apiResponse;
  }

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan');
    }

    print('Retrieved token from storage: ${token.substring(0, 20)}...');
    return token;
  }

  Future<ApiResponse> getActiveBookings() async {
    ApiResponse apiResponse = ApiResponse();

    try {
      String token = await getToken();
      print('Fetching active bookings with token...');

      final response = await http.get(
        Uri.parse('$baseURL/bookings'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token
        },
      );

      print('Bookings Response Status: ${response.statusCode}');
      print('Bookings Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Parsed response data: $responseData');

        if (responseData['data'] != null) {
          List<Booking> bookings = [];
          for (var item in responseData['data']) {
            try {
              print('Processing booking item: $item');
              final booking = Booking.fromJson(item);
              print(
                  'Booking parsed - Code: ${booking.bookingCode}, Status: ${booking.status}, Payment Status: ${booking.paymentStatus}');
              bookings.add(booking);
            } catch (e) {
              print('Error parsing booking item: $e');
            }
          }
          apiResponse.data = bookings;
          print('Successfully processed ${bookings.length} bookings');
        } else {
          print('No bookings data found in response');
          apiResponse.data = [];
        }
      } else if (response.statusCode == 401) {
        throw Exception('Sesi telah berakhir. Silakan login kembali');
      } else {
        throw Exception('Gagal memuat tiket');
      }
    } catch (e) {
      print('Error in getActiveBookings: $e');
      apiResponse.error = e.toString().replaceAll('Exception: ', '');
    }

    return apiResponse;
  }

  Future<ApiResponse> checkPaymentStatus(String bookingId) async {
    ApiResponse apiResponse = ApiResponse();

    try {
      String token = await getToken();
      print('Checking payment status for booking ID: $bookingId');

      final response = await http.get(
        Uri.parse('$baseURL/bookings/$bookingId/payment-status'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token
        },
      );

      print('Payment status check response: ${response.statusCode}');
      print('Payment status response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final status = responseData['status'] ?? responseData['payment_status'];
        print('Parsed payment status: $status');
        apiResponse.data = status;
      } else {
        print('Error response from payment status check');
        throw Exception('Gagal memeriksa status pembayaran');
      }
    } catch (e) {
      print('Error checking payment status: $e');
      apiResponse.error = e.toString();
    }

    return apiResponse;
  }
}
