import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tiketBus/constant.dart';
import 'package:tiketBus/models/api_response.dart';
import 'package:tiketBus/models/route.dart';

// Create new route
Future<ApiResponse> createRoute(String departure, String destination) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    final response = await http.post(
      Uri.parse(routeURL),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'departure': departure,
        'destination': destination,
      }),
    );

    switch (response.statusCode) {
      case 200:
      case 201:
        apiResponse.data = BusRoute.fromJson(jsonDecode(response.body));
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

// Get all routes
Future<ApiResponse> getRoutes() async {
  ApiResponse apiResponse = ApiResponse();
  try {
    final response = await http.get(
      Uri.parse(routeURL),
      headers: {
        'Accept': 'application/json',
      },
    );

    switch (response.statusCode) {
      case 200:
        List<dynamic> routeList = jsonDecode(response.body)['routes'];
        List<BusRoute> routes =
            routeList.map((p) => BusRoute.fromJson(p)).toList();
        apiResponse.data = routes;
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
