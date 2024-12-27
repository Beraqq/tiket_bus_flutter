import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_response.dart';
import '../models/payment.dart';
import '../constant.dart';

class PaymentService {
  Future<ApiResponse> createPayment({
    required String bookingId,
    required double amount,
    required String method,
  }) async {
    ApiResponse apiResponse = ApiResponse();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        apiResponse.error = unauthorized;
        return apiResponse;
      }

      print('Creating payment with:');
      print('Booking ID: $bookingId');
      print('Amount: $amount');
      print('Method: $method');

      final response = await http.post(
        Uri.parse('$paymentURL/create'),
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

      print('Payment response status: ${response.statusCode}');
      print('Payment response body: ${response.body}');

      switch (response.statusCode) {
        case 200:
          final responseData = jsonDecode(response.body);
          apiResponse.data = Payment.fromJson(responseData);
          break;
        case 401:
          apiResponse.error = unauthorized;
          break;
        case 400:
          final responseData = jsonDecode(response.body);
          apiResponse.error = responseData['message'] ?? 'Bad Request';
          break;
        default:
          apiResponse.error = somethingWentWrong;
          break;
      }
    } catch (e) {
      print('Error in createPayment: $e');
      apiResponse.error = serverError;
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

  Future<ApiResponse> checkPaymentStatus(String bookingId) async {
    ApiResponse apiResponse = ApiResponse();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        apiResponse.error = unauthorized;
        return apiResponse;
      }

      final response = await http.get(
        Uri.parse('$paymentURL/status/$bookingId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      switch (response.statusCode) {
        case 200:
          final responseData = jsonDecode(response.body);
          apiResponse.data = Payment.fromJson(responseData);
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
