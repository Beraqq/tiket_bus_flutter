import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tiketBus/models/api_response.dart';

import '../constant.dart';
import '../models/bus.dart';

Future<ApiResponse> getBuses() async {
  ApiResponse apiResponse = ApiResponse();

  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      apiResponse.error = 'Not authenticated';
      return apiResponse;
    }

    print('Using token: $token');

    final response = await http.get(
      Uri.parse('$baseURL/buses'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    switch (response.statusCode) {
      case 200:
        List<dynamic> data = jsonDecode(response.body);
        List<Bus> buses = data.map((bus) => Bus.fromJson(bus)).toList();
        apiResponse.data = buses;
        apiResponse.error = null;
        break;
      case 401:
        apiResponse.error = 'Session expired. Please login again';
        break;
      default:
        apiResponse.error = 'Failed to load buses: ${response.statusCode}';
        break;
    }
  } catch (e) {
    print('Error getting buses: $e');
    apiResponse.error = 'Network error: Unable to connect to server';
  }

  return apiResponse;
}

Future<Bus?> getBusByClass(String busClass) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print('Token not found');
      return null;
    }

    // Debug print untuk URL dan class yang dicari
    print('Fetching bus for class: $busClass');
    final url = Uri.parse('$baseURL/buses/class/$busClass');
    print('Request URL: $url');

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Jika response adalah list, ambil item pertama
      if (data is List && data.isNotEmpty) {
        return Bus.fromJson(data[0]);
      }
      // Jika response adalah single object
      else if (data is Map<String, dynamic>) {
        return Bus.fromJson(data);
      }

      print('No bus found for class: $busClass');
      return null;
    } else {
      print('Error fetching bus: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Exception in getBusByClass: $e');
    return null;
  }
}

// Tambahkan fungsi untuk mendapatkan bus berdasarkan class dari list buses
Bus? getBusFromListByClass(List<Bus> buses, String busClass) {
  try {
    return buses.firstWhere(
      (bus) => bus.busClass?.toLowerCase() == busClass.toLowerCase(),
    );
  } catch (e) {
    print('No bus found in list for class: $busClass');
    return null;
  }
}
