import 'schedule.dart';
import 'user.dart';
import 'dart:convert';

class Booking {
  final String? id;
  final String? bookingCode;
  final List<String>? seatNumbers;
  final double? totalPrice;
  final String? status;
  final String? paymentStatus;
  final DateTime? paymentDeadline;
  final Schedule? schedule;

  Booking({
    this.id,
    this.bookingCode,
    this.seatNumbers,
    this.totalPrice,
    this.status,
    this.paymentStatus,
    this.paymentDeadline,
    this.schedule,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    List<String> parseSeatNumbers(dynamic seatData) {
      print('Raw seat data: $seatData');

      if (seatData == null) return [];

      if (seatData is String) {
        if (seatData.contains(',')) {
          return seatData.split(',').map((s) => s.trim()).toList();
        }
        return [seatData];
      }

      if (seatData is List) {
        return seatData.map((seat) => seat.toString()).toList();
      }

      if (seatData is Map) {
        return seatData.values.map((seat) => seat.toString()).toList();
      }

      if (seatData is String && seatData.startsWith('[')) {
        try {
          List<dynamic> parsed = jsonDecode(seatData);
          return parsed.map((seat) => seat.toString()).toList();
        } catch (e) {
          print('Error parsing JSON seat data: $e');
        }
      }

      return [];
    }

    print('Parsing booking data: ${json['booking_code']}');
    print('Seat data from API: ${json['seat_numbers'] ?? json['seat_number']}');

    var seatNumbers =
        parseSeatNumbers(json['seat_numbers'] ?? json['seat_number']);
    print('Parsed seat numbers: $seatNumbers');

    return Booking(
      id: json['id']?.toString(),
      bookingCode: json['booking_code']?.toString(),
      seatNumbers: seatNumbers,
      totalPrice: double.tryParse(json['total_price']?.toString() ?? '0'),
      status: json['status']?.toString(),
      paymentStatus: json['payment_status']?.toString(),
      paymentDeadline: json['payment_deadline'] != null
          ? DateTime.tryParse(json['payment_deadline'].toString())
          : null,
      schedule:
          json['schedule'] != null ? Schedule.fromJson(json['schedule']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      // 'booking_id': bookingId,
      'booking_code': bookingCode,
      'seat_number': seatNumbers,
      'total_price': totalPrice,
      'status': status,
      'payment_status': paymentStatus,
      'payment_deadline': paymentDeadline?.toIso8601String(),
      'schedule': schedule?.toJson(),
    };
  }

  void debugPrintSeatNumbers() {
    print('Booking Code: $bookingCode');
    print('Seat Numbers: $seatNumbers');
  }
}
