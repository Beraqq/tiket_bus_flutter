class Bus {
  final int? id;
  final String? busCode;
  final String? busClass;
  final String? facilities;
  final int? totalSeats;
  final double? pricePerSeat;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Bus({
    this.id,
    this.busCode,
    this.busClass,
    this.facilities,
    this.totalSeats,
    this.pricePerSeat,
    this.createdAt,
    this.updatedAt,
  });

  factory Bus.fromJson(Map<String, dynamic> json) {
    try {
      return Bus(
        id: json['id'],
        busCode: json['bus_code'],
        busClass: json['class'],
        facilities: json['facilities'],
        totalSeats: json['total_seats'],
        pricePerSeat: json['price_per_seat'] is String
            ? double.tryParse(json['price_per_seat'])
            : json['price_per_seat']?.toDouble(),
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'])
            : null,
      );
    } catch (e) {
      print('Error parsing Bus JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bus_code': busCode,
      'class': busClass,
      'facilities': facilities,
      'total_seats': totalSeats,
      'price_per_seat': pricePerSeat,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
