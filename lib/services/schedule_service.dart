import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tiketBus/constant.dart';
import 'package:tiketBus/models/api_response.dart';
import 'package:tiketBus/models/schedule.dart';

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
Future<ApiResponse> getAvailableSchedules(String routeId, DateTime date) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    final response = await http.get(
      Uri.parse('$scheduleURL/available/$routeId/${date.toIso8601String()}'),
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
