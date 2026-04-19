import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class OSRMService01 {
  static final OSRMService01 _instance = OSRMService01._internal();

  OSRMService01._internal();

  factory OSRMService01() => _instance;

  /// Base URLs
  final String _routeUrl = 'http://router.project-osrm.org/route/v1';
  final String _tableUrl = 'http://router.project-osrm.org/table/v1';

  /// This is for individual distance mapping
  Future<double> getDistanceByLatLng(LatLng start, LatLng end) async {
    final url = Uri.parse(
      '$_routeUrl/driving/'
      '${start.longitude},${start.latitude};'
      '${end.longitude},${end.latitude}?overview=false',
    );

    final res = await http.get(url);
    final data = jsonDecode(res.body);

    if (data['routes'] == null || data['routes'].isEmpty) {
      throw Exception("No route found");
    }

    return (data['routes'][0]['distance'] as num).toDouble();
  }

  /// This is able to send multiple distances
  Future<List<double>> distanceFromTable(
    LatLng start,
    List<LatLng> destinations,
  ) async {
    if (destinations.isEmpty) return [];

    final coords = [
      '${start.longitude},${start.latitude}',
      ...destinations.map((d) => '${d.longitude},${d.latitude}'),
    ].join(';');

    final url = Uri.parse(
      '$_tableUrl/driving/$coords?sources=0&annotations=distance',
    );

    final res = await http.get(url);
    final data = jsonDecode(res.body);

    if (data['distances'] == null) {
      throw Exception("No distances found");
    }

    final List distances = data['distances'][0];

    return distances.skip(1).map((d) => (d as num).toDouble()).toList();
  }
}
