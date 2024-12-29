import 'package:flutter/material.dart';

const String baseURL = 'http://192.168.1.8:8000/api';
const String loginURL = baseURL + '/login';
const String registerURL = baseURL + '/register';
const String logoutURL = baseURL + '/logout';
const String profileURL = baseURL + '/profile';
const String routeURL = baseURL + '/routes';
const String scheduleURL = baseURL + '/schedules';
const String busURL = baseURL + '/buses';
const String bookingURL = baseURL + '/bookings';
const String paymentURL = baseURL + '/payments';
const String historyURL = baseURL + '/history';

// Error messages
const String serverError = 'Terjadi kesalahan pada server';
const String unauthorized = 'Sesi telah berakhir. Silakan login kembali';
const String somethingWentWrong = 'Terjadi kesalahan. Silakan coba lagi';

// Success messages
const String loginSuccess = 'Login berhasil';
const String registerSuccess = 'Registrasi berhasil';
const String logoutSuccess = 'Logout berhasil';

// Validation messages
const String emailRequired = 'Email tidak boleh kosong';
const String passwordRequired = 'Password tidak boleh kosong';
const String nameRequired = 'Nama tidak boleh kosong';
const String invalidEmail = 'Format email tidak valid';
const String passwordLength = 'Password minimal 6 karakter';
const String passwordNotMatch = 'Password tidak cocok';

// Payment Status
const String paymentPending = 'pending';
const String paymentSuccess = 'success';
const String paymentFailed = 'failed';

// Booking Status
const String bookingPending = 'pending';
const String bookingActive = 'active';
const String bookingCompleted = 'completed';
const String bookingCancelled = 'cancelled';

// input decoration
InputDecoration inputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    border: OutlineInputBorder(),
  );
}
