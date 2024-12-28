// Login
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiketBus/constant.dart';
import 'package:tiketBus/models/api_response.dart';
import 'package:http/http.dart' as http;
import 'package:tiketBus/models/user.dart';

// Get token
Future<String> getToken() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    print('Attempting to get token from SharedPreferences');
    print('Retrieved token: $token');

    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan');
    }

    return token;
  } catch (e) {
    print('Error getting token: $e');
    throw Exception('Token tidak ditemukan');
  }
}

// Get user id
Future<int?> getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('userId');
}

// Login
Future<ApiResponse> login(String email, String password) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    print('Attempting login for email: $email');

    final response = await http.post(
      Uri.parse('$baseURL/login'),
      headers: {'Accept': 'application/json'},
      body: {'email': email, 'password': password},
    );

    print('Login Response Status: ${response.statusCode}');
    print('Login Response Raw Body: ${response.body}');

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      // Simpan token
      final token = responseData['token'];
      print('Token from response: $token');

      if (token != null && token.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        final bearerToken = 'Bearer $token';

        // Simpan token
        await prefs.setString('token', bearerToken);
        print('Token saved to SharedPreferences: $bearerToken');

        // Verifikasi token tersimpan
        final verifyToken = prefs.getString('token');
        print('Verified token in SharedPreferences: $verifyToken');

        if (verifyToken == null || verifyToken.isEmpty) {
          throw Exception('Gagal menyimpan token');
        }

        // Simpan data user
        if (responseData['user'] != null) {
          final userData = responseData['user'];
          await Future.wait([
            prefs.setString('name', userData['name'] ?? ''),
            prefs.setString('email', userData['email'] ?? ''),
            prefs.setString('phone', userData['phone'] ?? ''),
            prefs.setInt('userId', userData['id'] ?? 0),
          ]);

          final user = User(
            id: userData['id'],
            name: userData['name'],
            email: userData['email'],
            phone: userData['phone'],
            token: bearerToken,
          );

          apiResponse.data = user;
          print('User data saved successfully');
        }
      } else {
        throw Exception('Token tidak ditemukan dalam response');
      }
    } else {
      final responseBody = jsonDecode(response.body);
      throw Exception(responseBody['message'] ?? 'Login gagal');
    }
  } catch (e) {
    print('Error during login: $e');
    apiResponse.error = e.toString().replaceAll('Exception: ', '');
  }
  return apiResponse;
}

// Tambahkan fungsi untuk verifikasi token
Future<bool> verifyToken() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      print('No token found in storage');
      return false;
    }

    print('Token exists in storage: ${token.substring(0, 20)}...');
    return true;
  } catch (e) {
    print('Error verifying token: $e');
    return false;
  }
}

// Register
Future<ApiResponse> register(String name, String email, String password) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    print('Registering user:');
    print('Name: $name');
    print('Email: $email');

    final response = await http.post(
      Uri.parse('$baseURL/register'),
      headers: {'Accept': 'application/json'},
      body: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password
      },
    );

    print('Register Response Status: ${response.statusCode}');
    print('Register Response Body: ${response.body}');

    switch (response.statusCode) {
      case 200:
      case 201:
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          apiResponse.data = responseData['message'];
        } else {
          throw Exception(responseData['message'] ?? 'Registration failed');
        }
        break;
      case 422:
        final errors = jsonDecode(response.body)['errors'];
        apiResponse.error = errors[errors.keys.first][0];
        break;
      default:
        apiResponse.error = somethingWentWrong;
        break;
    }
  } catch (e) {
    print('Error during registration: $e');
    apiResponse.error = serverError;
  }
  return apiResponse;
}

// User
Future<ApiResponse> getUserDetail() async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.get(
      Uri.parse('$baseURL/user'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    switch (response.statusCode) {
      case 200:
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          apiResponse.data = User.fromJson(responseData['data']);
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to get user details');
        }
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

// Update user
Future<ApiResponse> updateUser(String name, String? phone) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.put(
      Uri.parse('$baseURL/user'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      body: {
        'name': name,
        if (phone != null) 'phone': phone,
      },
    );

    switch (response.statusCode) {
      case 200:
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('name', name);
          if (phone != null) {
            await prefs.setString('phone', phone);
          }
          apiResponse.data = responseData['message'];
        } else {
          throw Exception(responseData['message'] ?? 'Update failed');
        }
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

// Logout
Future<bool> logout() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    return true;
  } catch (e) {
    print('Error during logout: $e');
    return false;
  }
}

// Fungsi untuk mengecek status login
Future<bool> isLoggedIn() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null && token.isNotEmpty;
  } catch (e) {
    print('Error checking login status: $e');
    return false;
  }
}
