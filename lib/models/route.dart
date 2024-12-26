class BusRoute {
  String? routeId;
  String? departure;
  String? destination;

  BusRoute({
    this.routeId,
    this.departure,
    this.destination,
  });

  // Mengkonversi JSON ke objek BusRoute
  factory BusRoute.fromJson(Map<String, dynamic> json) {
    return BusRoute(
      routeId: json['route_id']?.toString(),
      departure: json['departure']?.toString(),
      destination: json['destination']?.toString(),
    );
  }

  // Mengkonversi objek BusRoute ke JSON
  Map<String, dynamic> toJson() {
    return {
      'route_id': routeId,
      'departure': departure,
      'destination': destination,
    };
  }
}
