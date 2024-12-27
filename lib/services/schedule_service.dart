import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:tiketBus/constant.dart';
import 'package:tiketBus/models/api_response.dart';
import 'package:tiketBus/models/schedule.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Get schedules by route
Future<ApiResponse> getSchedulesByRoute(String routeId) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    final response = await http.get(
      Uri.parse('$scheduleURL/route/$routeId'),
      headers: {
        'Accept': 'application/json',
      },
    );

    switch (response.statusCode) {
      case 200:
        List<dynamic> scheduleList = jsonDecode(response.body)['schedules'];
        List<Schedule> schedules =
            scheduleList.map((p) => Schedule.fromJson(p)).toList();
        apiResponse.data = schedules;
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
    print('Exception: $e');
  }
  return apiResponse;
}

// Get schedule by ID
Future<ApiResponse> getScheduleById(String scheduleId) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    final response = await http.get(
      Uri.parse('$scheduleURL/$scheduleId'),
      headers: {
        'Accept': 'application/json',
      },
    );

    switch (response.statusCode) {
      case 200:
        apiResponse.data =
            Schedule.fromJson(jsonDecode(response.body)['schedule']);
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
    print('Exception: $e');
  }
  return apiResponse;
}

// Get available schedules by date and route
Future<ApiResponse> getAvailableSchedules(String busCode, DateTime date) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    // Ambil token dari SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print('Token not found');
      apiResponse.error = 'Silakan login terlebih dahulu';
      return apiResponse;
    }

    String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    print('Fetching schedules with:');
    print('Bus Code: $busCode');
    print('Date: $formattedDate');
    print('Token: $token'); // Debug print token

    final response = await http.get(
      Uri.parse('$scheduleURL/available/$busCode/$formattedDate'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Tambahkan token ke header
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    switch (response.statusCode) {
      case 200:
        final responseData = jsonDecode(response.body);
        if (responseData['schedules'] != null) {
          apiResponse.data = responseData['schedules'];
        } else {
          apiResponse.error = 'Tidak ada jadwal tersedia';
        }
        break;
      case 401:
        print('Unauthorized: Token might be invalid or expired');
        apiResponse.error = 'Sesi telah berakhir, silakan login kembali';
        // Hapus token karena sudah tidak valid
        await prefs.remove('token');
        break;
      case 404:
        apiResponse.error = 'Jadwal tidak ditemukan';
        break;
      default:
        print('Unexpected status code: ${response.statusCode}');
        apiResponse.error = somethingWentWrong;
        break;
    }
  } catch (e) {
    print('Error in getAvailableSchedules: $e');
    apiResponse.error = serverError;
  }
  return apiResponse;
}

// Tambahkan fungsi createSchedule
Future<ApiResponse> createSchedule(String routeId, DateTime departureDate,
    String busCode, int selectedSeats) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    final response = await http.post(
      Uri.parse(scheduleURL),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'route_id': routeId,
        'departure_date': departureDate.toIso8601String(),
        'bus_code': busCode,
        'selected_seats': selectedSeats
      }),
    );

    switch (response.statusCode) {
      case 200:
      case 201:
        apiResponse.data = Schedule.fromJson(jsonDecode(response.body));
        break;
      case 422:
        final errors = jsonDecode(response.body)['errors'];
        apiResponse.error = errors[errors.keys.elementAt(0)][0];
        break;
      default:
        apiResponse.error = somethingWentWrong;
        break;
    }
  } catch (e) {
    apiResponse.error = serverError;
    print('Exception: $e');
  }
  return apiResponse;
}
