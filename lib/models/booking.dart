class Booking {
  final String? bookingId;
  final String? scheduleId;
  final int? seatNumber;
  final double? totalPrice;
  final String? status;
  final DateTime? paymentDeadline;

  Booking({
    this.bookingId,
    this.scheduleId,
    this.seatNumber,
    this.totalPrice,
    this.status,
    this.paymentDeadline,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      bookingId: json['booking_id'],
      scheduleId: json['schedule_id'],
      seatNumber: json['seat_number'],
      totalPrice: json['total_price']?.toDouble(),
      status: json['status'],
      paymentDeadline: json['payment_deadline'] != null
          ? DateTime.parse(json['payment_deadline'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'schedule_id': scheduleId,
      'seat_number': seatNumber,
      'total_price': totalPrice,
      'status': status,
      'payment_deadline': paymentDeadline?.toIso8601String(),
    };
  }

  bool isValid() {
    if (paymentDeadline == null) return false;
    return DateTime.now().isBefore(paymentDeadline!);
  }

  bool isPaid() {
    return status?.toLowerCase() == 'paid';
  }

  bool isPending() {
    return status?.toLowerCase() == 'pending';
  }
}
