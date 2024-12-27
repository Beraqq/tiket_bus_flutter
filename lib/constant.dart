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
const String serverError = 'Server error';
const String unauthorized = 'Unauthorized';
const String somethingWentWrong = 'Something went wrong';

// input decoration
InputDecoration inputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    border: OutlineInputBorder(),
  );
}
