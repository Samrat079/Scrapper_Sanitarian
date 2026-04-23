import 'package:latlong2/latlong.dart';

class RoutesResponse {
  double distance;
  List<LatLng> coordinates;
  Duration duration;

  RoutesResponse({
    this.distance = 0,
    this.duration = Duration.zero,
    this.coordinates = const [],
  });

  factory RoutesResponse.fromJson(Map<String, dynamic> json) {
    final seconds = (json['duration'] as num).toDouble();

    return RoutesResponse(
      distance: (json['distance'] as num).toDouble(),
      duration: Duration(seconds: seconds.round()),
      coordinates: (json['geometry']['coordinates'] as List)
          .map<LatLng>((c) => LatLng(c[1], c[0]))
          .toList(),
    );
  }

  void fromTable(double meters, Duration seconds) {
    distance = meters;
    duration = seconds;
  }
}
