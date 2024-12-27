class Schedule {
  final String? scheduleId;
  final String? busCode;
  final String? routeId;
  final DateTime? departureDate;
  final String? departureTime;
  final int availableSeats;

  Schedule({
    this.scheduleId,
    this.busCode,
    this.routeId,
    this.departureDate,
    this.departureTime,
    required this.availableSeats,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      scheduleId: json['schedule_id'],
      busCode: json['bus_code'],
      routeId: json['route_id'],
      departureDate: json['departure_date'] != null
          ? DateTime.parse(json['departure_date'])
          : null,
      departureTime: json['departure_time'],
      availableSeats: json['available_seats'] ?? 0,
    );
  }
}
