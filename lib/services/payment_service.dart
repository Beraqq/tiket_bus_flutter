import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_response.dart';
import '../models/payment.dart';
import '../constant.dart';
import 'user_service.dart';

class PaymentService {
  Future<ApiResponse> createPayment({
    required String bookingId,
    required double amount,
    required String method,
  }) async {
    ApiResponse apiResponse = ApiResponse();

    try {
      String token = await getToken();

      print('Creating payment with data:');
      print('Booking ID: $bookingId');
      print('Amount: $amount');
      print('Method: $method');

      final response = await http.post(
        Uri.parse('$baseURL/bookings/$bookingId/complete-payment'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({
          'amount': amount,
          'payment_method': method,
        }),
      );

      print('Payment Response Status: ${response.statusCode}');
      print('Payment Response Body: ${response.body}');

      switch (response.statusCode) {
        case 200:
        case 201:
          final responseData = jsonDecode(response.body);
          if (responseData['status'] == 'success' &&
              responseData['data'] != null) {
            // Parse response ke model Payment
            apiResponse.data = Payment.fromJson(responseData['data']);
          } else {
            throw Exception(
                responseData['message']?.toString() ?? 'Payment failed');
          }
          break;
        case 401:
          throw Exception('Unauthorized');
        case 404:
          throw Exception('Booking not found');
        case 422:
          final responseBody = jsonDecode(response.body);
          throw Exception(
              responseBody['message']?.toString() ?? 'Validation error');
        default:
          final responseBody = jsonDecode(response.body);
          throw Exception(
              responseBody['message']?.toString() ?? 'Payment failed');
      }
    } catch (e) {
      print('Error in payment service: $e');
      apiResponse.error = e.toString().replaceAll('Exception: ', '');
    }

    return apiResponse;
  }

  Future<ApiResponse> uploadPaymentProof({
    required String paymentId,
    required String filePath,
  }) async {
    ApiResponse apiResponse = ApiResponse();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Sesi telah berakhir');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseURL/payments/$paymentId/upload-proof'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.files.add(
        await http.MultipartFile.fromPath('payment_proof', filePath),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        apiResponse.data = Payment.fromJson(responseData['data']);
      } else {
        throw Exception(responseData['message']);
      }
    } catch (e) {
      apiResponse.error = e.toString().replaceAll('Exception: ', '');
    }
    return apiResponse;
  }

  Future<ApiResponse> checkPaymentStatus(String paymentId) async {
    ApiResponse apiResponse = ApiResponse();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Sesi telah berakhir');
      }

      final response = await http.get(
        Uri.parse('$baseURL/payments/$paymentId/status'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        apiResponse.data = Payment.fromJson(responseData['data']);
      } else {
        throw Exception(responseData['message']);
      }
    } catch (e) {
      apiResponse.error = e.toString().replaceAll('Exception: ', '');
    }
    return apiResponse;
  }
}
