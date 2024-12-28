import 'schedule.dart';
import 'user.dart';

class Booking {
  final String? id;
  final String? bookingId;
  final String? scheduleId;
  final int? seatNumber;
  final double? totalPrice;
  final String? status;
  final Schedule? schedule;
  final User? user;

  Booking({
    this.id,
    this.bookingId,
    this.scheduleId,
    this.seatNumber,
    this.totalPrice,
    this.status,
    this.schedule,
    this.user,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id']?.toString(),
      bookingId: json['id']?.toString(),
      scheduleId: json['schedule_id']?.toString(),
      seatNumber: json['seat_number'],
      totalPrice: json['total_price']?.toDouble(),
      status: json['status'],
      schedule:
          json['schedule'] != null ? Schedule.fromJson(json['schedule']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': bookingId,
      'schedule_id': scheduleId,
      'seat_number': seatNumber,
      'total_price': totalPrice,
      'status': status,
    };
  }
}
