// Login
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiketBus/constant.dart';
import 'package:tiketBus/models/api_response.dart';
import 'package:http/http.dart' as http;
import 'package:tiketBus/models/user.dart';

// login
Future<ApiResponse> login(String email, String password) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    final response = await http.post(Uri.parse(loginURL),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'email': email, 'password': password}));

    print('Login URL: $loginURL');
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    switch (response.statusCode) {
      case 200:
        apiResponse.data = jsonDecode(response.body);
        apiResponse.error = null;
        break;
      case 401:
        apiResponse.error = unauthorized;
        break;
      default:
        apiResponse.error = somethingWentWrong;
        break;
    }
  } catch (e) {
    print('Exception during login: $e');
    apiResponse.error = serverError;
  }
  return apiResponse;
}

// Register
Future<ApiResponse> register(
    String name, String phone, String email, String password) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    final response = await http.post(Uri.parse(registerURL),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'name': name,
          'phone': phone,
          'email': email,
          'password': password,
          'password_confirmation': password,
        }));

    print('Register URL: $registerURL');
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      apiResponse.data = responseData; // Simpan response data langsung
      apiResponse.error = null;
    } else {
      switch (response.statusCode) {
        case 422:
          final errors = responseData['errors'];
          apiResponse.error = errors[errors.keys.elementAt(0)][0];
          break;
        case 403:
          apiResponse.error = responseData['message'];
          break;
        default:
          apiResponse.error = somethingWentWrong;
          break;
      }
    }
  } catch (e) {
    print('Exception during registration: $e');
    apiResponse.error = serverError;
  }
  return apiResponse;
}

// user profile
Future<ApiResponse> getUserDetail(String token) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.get(
      Uri.parse(profileURL),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    switch (response.statusCode) {
      case 200:
        apiResponse.data = User.fromJson(jsonDecode(response.body));
        break;
      case 401:
        apiResponse.error = unauthorized;
        break;
      default:
        apiResponse.error = somethingWentWrong;
    }
  } catch (e) {
    apiResponse.error = serverError;
  }
  return apiResponse;
}

// get token
Future<String> getToken() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getString('token') ?? '';
}

// get user id
Future<int> getUserId() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getInt('id') ?? 0;
}

// logout
Future<bool> logout() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    // Hapus semua data user
    await prefs.remove('token');
    await prefs.remove('name');
    await prefs.remove('email');
    await prefs.remove('phone');
    return true;
  } catch (e) {
    return false;
  }
}
