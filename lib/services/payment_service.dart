import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_response.dart';
import '../models/payment.dart';
import '../constant.dart';

class PaymentService {
  Future<ApiResponse> createPayment(
      {required String bookingId,
      required double amount,
      required String method}) async {
    ApiResponse apiResponse = ApiResponse();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Sesi telah berakhir');
      }

      print('Creating payment with data:');
      print('Booking ID: $bookingId');
      print('Amount: $amount');

      final response = await http.post(
        Uri.parse('$baseURL/payments/create'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'booking_id': bookingId,
          'amount': amount,
        }),
      );

      print('Payment Response Status: ${response.statusCode}');
      print('Payment Response Body: ${response.body}');

      if (response.body.isEmpty) {
        throw Exception('Server returned empty response');
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseData['status'] == 'success' &&
            responseData['data'] != null) {
          apiResponse.data = {
            'snap_token': responseData['data']['snap_token'],
            'payment': Payment.fromJson(responseData['data']['payment']),
          };
          print('Payment data processed successfully');
        } else {
          throw Exception(
              responseData['message'] ?? 'Gagal membuat pembayaran');
        }
      } else {
        throw Exception(responseData['message'] ?? 'Gagal membuat pembayaran');
      }
    } catch (e) {
      print('Error creating payment: $e');
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
