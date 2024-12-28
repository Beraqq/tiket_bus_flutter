class Bus {
  final String? busCode;
  final String? busName;
  final String? busClass;
  final int? totalSeats;
  final int? capacity;
  final double? pricePerSeat;

  Bus({
    this.busCode,
    this.busName,
    this.busClass,
    this.totalSeats,
    this.capacity,
    this.pricePerSeat,
  });

  factory Bus.fromJson(Map<String, dynamic> json) {
    return Bus(
      busCode: json['bus_code']?.toString(),
      busName: json['bus_name']?.toString(),
      busClass: json['bus_class']?.toString(),
      totalSeats: int.tryParse(json['total_seats']?.toString() ?? '0'),
      capacity: int.tryParse(json['capacity']?.toString() ?? '0'),
      pricePerSeat: double.tryParse(json['price_per_seat']?.toString() ?? '0'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bus_code': busCode,
      'bus_name': busName,
      'bus_class': busClass,
      'total_seats': totalSeats,
      'capacity': capacity,
      'price_per_seat': pricePerSeat,
    };
  }
}
