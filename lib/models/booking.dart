class Booking {
  final int? id;
  final int? userId;
  final String? scheduleId;
  final int? seatNumber;
  final double? totalPrice;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Booking({
    this.id,
    this.userId,
    this.scheduleId,
    this.seatNumber,
    this.totalPrice,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    try {
      return Booking(
        id: json['id'],
        userId: json['user_id'],
        scheduleId: json['schedule_id'],
        seatNumber: json['seat_number'],
        totalPrice: json['total_price'] is String
            ? double.tryParse(json['total_price'])
            : json['total_price']?.toDouble(),
        status: json['status'],
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'])
            : null,
      );
    } catch (e) {
      print('Error parsing Booking JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'schedule_id': scheduleId,
      'seat_number': seatNumber,
      'total_price': totalPrice,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
