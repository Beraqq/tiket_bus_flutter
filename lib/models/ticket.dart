import 'booking.dart';

class Ticket {
  final int? id;
  final int? bookingId;
  final String? ticketCode;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  Booking? booking; // Relasi dengan booking

  Ticket({
    this.id,
    this.bookingId,
    this.ticketCode,
    this.createdAt,
    this.updatedAt,
    this.booking,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'],
      bookingId: json['booking_id'],
      ticketCode: json['ticket_code'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      booking:
          json['booking'] != null ? Booking.fromJson(json['booking']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'ticket_code': ticketCode,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'booking': booking?.toJson(),
    };
  }
}
