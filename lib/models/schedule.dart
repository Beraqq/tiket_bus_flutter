import 'bus.dart';

class Schedule {
  final String? scheduleId;
  final String? busCode;
  final String? routeId;
  final String origin;
  final String destination;
  final String? departureTime;
  final String? arrivalTime;
  final int availableSeats;
  final Bus? bus;
  final String? originDetail;
  final String? destinationDetail;

  Schedule({
    this.scheduleId,
    this.busCode,
    this.routeId,
    required this.origin,
    required this.destination,
    this.departureTime,
    this.arrivalTime,
    required this.availableSeats,
    this.bus,
    this.originDetail,
    this.destinationDetail,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      scheduleId: json['schedule_id']?.toString(),
      busCode: json['bus_code']?.toString(),
      routeId: json['route_id']?.toString(),
      origin: json['origin'] ?? '',
      destination: json['destination'] ?? '',
      departureTime: json['departure_time']?.toString(),
      arrivalTime: json['arrival_time']?.toString(),
      availableSeats:
          int.tryParse(json['available_seats']?.toString() ?? '0') ?? 0,
      bus: json['bus'] != null ? Bus.fromJson(json['bus']) : null,
      originDetail: json['origin_detail']?.toString(),
      destinationDetail: json['destination_detail']?.toString(),
    );
  }

  DateTime? get departureDateTime {
    if (departureTime == null) return null;
    try {
      return DateTime.parse(departureTime!);
    } catch (e) {
      print('Error parsing departure time: $e');
      return null;
    }
  }

  DateTime? get arrivalDateTime {
    if (arrivalTime == null) return null;
    try {
      return DateTime.parse(arrivalTime!);
    } catch (e) {
      print('Error parsing arrival time: $e');
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'schedule_id': scheduleId,
      'bus_code': busCode,
      'route_id': routeId,
      'origin': origin,
      'destination': destination,
      'departure_time': departureTime,
      'arrival_time': arrivalTime,
      'available_seats': availableSeats,
      'bus': bus?.toJson(),
      'origin_detail': originDetail,
      'destination_detail': destinationDetail,
    };
  }
}
