import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_response.dart';
import '../models/ticket.dart';

class TicketService {
  // Mendapatkan semua tiket user
  Future<ApiResponse> getTickets() async {
    ApiResponse apiResponse = ApiResponse();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        apiResponse.error = 'Not authenticated';
        return apiResponse;
      }

      final response = await http.get(
        Uri.parse('baseURL/tickets'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      switch (response.statusCode) {
        case 200:
          List<dynamic> data = jsonDecode(response.body);
          apiResponse.data = data.map((p) => Ticket.fromJson(p)).toList();
          break;
        case 401:
          apiResponse.error = 'Unauthorized';
          break;
        default:
          apiResponse.error = 'Failed to load tickets';
          break;
      }
    } catch (e) {
      apiResponse.error = 'Server error: $e';
    }
    return apiResponse;
  }

  // Mendapatkan detail tiket berdasarkan ID
  Future<ApiResponse> getTicketById(int ticketId) async {
    ApiResponse apiResponse = ApiResponse();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        apiResponse.error = 'Not authenticated';
        return apiResponse;
      }

      final response = await http.get(
        Uri.parse('baseURL/tickets/$ticketId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      switch (response.statusCode) {
        case 200:
          apiResponse.data = Ticket.fromJson(jsonDecode(response.body));
          break;
        case 401:
          apiResponse.error = 'Unauthorized';
          break;
        case 404:
          apiResponse.error = 'Ticket not found';
          break;
        default:
          apiResponse.error = 'Failed to load ticket';
          break;
      }
    } catch (e) {
      apiResponse.error = 'Server error: $e';
    }
    return apiResponse;
  }

  // Mendapatkan tiket berdasarkan kode tiket
  Future<ApiResponse> getTicketByCode(String ticketCode) async {
    ApiResponse apiResponse = ApiResponse();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        apiResponse.error = 'Not authenticated';
        return apiResponse;
      }

      final response = await http.get(
        Uri.parse('baseURL/tickets/code/$ticketCode'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      switch (response.statusCode) {
        case 200:
          apiResponse.data = Ticket.fromJson(jsonDecode(response.body));
          break;
        case 401:
          apiResponse.error = 'Unauthorized';
          break;
        case 404:
          apiResponse.error = 'Ticket not found';
          break;
        default:
          apiResponse.error = 'Failed to load ticket';
          break;
      }
    } catch (e) {
      apiResponse.error = 'Server error: $e';
    }
    return apiResponse;
  }

  // Generate PDF tiket
  Future<ApiResponse> generateTicketPDF(int ticketId) async {
    ApiResponse apiResponse = ApiResponse();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        apiResponse.error = 'Not authenticated';
        return apiResponse;
      }

      final response = await http.get(
        Uri.parse('baseURL/tickets/$ticketId/pdf'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      switch (response.statusCode) {
        case 200:
          apiResponse.data = response.body; // URL PDF atau base64 PDF
          break;
        case 401:
          apiResponse.error = 'Unauthorized';
          break;
        case 404:
          apiResponse.error = 'Ticket not found';
          break;
        default:
          apiResponse.error = 'Failed to generate ticket PDF';
          break;
      }
    } catch (e) {
      apiResponse.error = 'Server error: $e';
    }
    return apiResponse;
  }
}
