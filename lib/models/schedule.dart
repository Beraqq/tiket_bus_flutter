class Schedule {
  int? id;
  String? scheduleId;
  String? busCode;
  String? routeId;
  DateTime? departureDate;
  String? departureTime;
  int? availableSeats;
  int? selectedSeats;

  Schedule({
    this.id,
    this.scheduleId,
    this.busCode,
    this.routeId,
    this.departureDate,
    this.departureTime,
    this.availableSeats,
    this.selectedSeats,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      scheduleId: json['schedule_id'],
      busCode: json['bus_code'],
      routeId: json['route_id'],
      departureDate: json['departure_date'] != null
          ? DateTime.parse(json['departure_date'])
          : null,
      departureTime: json['departure_time'],
      availableSeats: json['available_seats'],
      selectedSeats: json['selected_seats'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'schedule_id': scheduleId,
      'bus_code': busCode,
      'route_id': routeId,
      'departure_date': departureDate?.toIso8601String(),
      'departure_time': departureTime,
      'available_seats': availableSeats,
      'selected_seats': selectedSeats,
    };
  }
}
