import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_response.dart';
import '../models/payment.dart';
import '../constant.dart';

class PaymentService {
  Future<ApiResponse> createPayment({
    required int bookingId,
    required double amount,
    required String method,
  }) async {
    ApiResponse apiResponse = ApiResponse();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        apiResponse.error = 'Not authenticated';
        return apiResponse;
      }

      final response = await http.post(
        Uri.parse('$baseURL/payments'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'booking_id': bookingId,
          'amount': amount,
          'method': method,
        }),
      );

      switch (response.statusCode) {
        case 201:
          apiResponse.data = Payment.fromJson(jsonDecode(response.body));
          break;
        case 401:
          apiResponse.error = 'Unauthorized';
          break;
        case 422:
          final errors = jsonDecode(response.body)['errors'];
          apiResponse.error = errors[errors.keys.first][0];
          break;
        default:
          apiResponse.error = 'Failed to create payment';
          break;
      }
    } catch (e) {
      apiResponse.error = 'Server error: $e';
    }
    return apiResponse;
  }

  Future<ApiResponse> uploadPaymentProof({
    required int paymentId,
    required String filePath,
  }) async {
    ApiResponse apiResponse = ApiResponse();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        apiResponse.error = 'Not authenticated';
        return apiResponse;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseURL/payments/$paymentId/proof'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.files.add(await http.MultipartFile.fromPath(
        'payment_proof',
        filePath,
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      switch (response.statusCode) {
        case 200:
          apiResponse.data = Payment.fromJson(jsonDecode(response.body));
          break;
        case 401:
          apiResponse.error = 'Unauthorized';
          break;
        default:
          apiResponse.error = 'Failed to upload payment proof';
          break;
      }
    } catch (e) {
      apiResponse.error = 'Server error: $e';
    }
    return apiResponse;
  }

  Future<ApiResponse> getPaymentStatus(int paymentId) async {
    ApiResponse apiResponse = ApiResponse();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        apiResponse.error = 'Not authenticated';
        return apiResponse;
      }

      final response = await http.get(
        Uri.parse('$baseURL/payments/$paymentId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      switch (response.statusCode) {
        case 200:
          apiResponse.data = Payment.fromJson(jsonDecode(response.body));
          break;
        case 401:
          apiResponse.error = 'Unauthorized';
          break;
        case 404:
          apiResponse.error = 'Payment not found';
          break;
        default:
          apiResponse.error = 'Failed to get payment status';
          break;
      }
    } catch (e) {
      apiResponse.error = 'Server error: $e';
    }
    return apiResponse;
  }
}
