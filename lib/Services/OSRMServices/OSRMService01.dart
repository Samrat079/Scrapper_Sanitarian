import 'dart:convert';
import 'dart:ffi';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../Models/RouteResponse/RouteResponse.dart';

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

  // Future<RoutesResponse> getRoutesByLatLng(LatLng start, LatLng end) async {
  //   final url = Uri.parse(
  //     '$_routeUrl/driving/'
  //         '${start.longitude},${start.latitude};'
  //         '${end.longitude},${end.latitude}?overview=false',
  //   );
  //
  //   final res = await http.get(url);
  //   final data = jsonDecode(res.body);
  //
  //   if (data['routes'] == null || data['routes'].isEmpty) {
  //     throw Exception("No route found");
  //   }
  //
  //   return data['routes'];
  // }

  /// This is able to send multiple distances
  Future<List<RoutesResponse>> distanceFromTable(
    LatLng start,
    List<LatLng> destinations,
  ) async {
    if (destinations.isEmpty) return [];

    final coords = [
      '${start.longitude},${start.latitude}',
      ...destinations.map((d) => '${d.longitude},${d.latitude}'),
    ].join(';');

    final url = Uri.parse(
      '$_tableUrl/driving/$coords?sources=0&annotations=distance,duration',
    );

    final res = await http.get(url);
    final data = jsonDecode(res.body);

    if (data['distances'] == null || data['durations'] == null) {
      throw Exception("No data found");
    }

    final List distances = data['distances'][0];
    final List durations = data['durations'][0];

    return List.generate(destinations.length, (i) {
      final distanceMeters = (distances[i + 1] as num).toDouble();
      final durationSeconds = (durations[i + 1] as num).toDouble();

      final result = RoutesResponse(
        distance: distanceMeters,
        duration: Duration(seconds: durationSeconds.round()),
        coordinates: [],
      );

      return result;
    });
  }

  /// Returns Route object, find it below
  Future<RoutesResponse> getRouteGeoJson(LatLng start, LatLng end) async {
    final url = Uri.parse(
      '$_routeUrl/driving/'
      '${start.longitude},${start.latitude};'
      '${end.longitude},${end.latitude}'
      '?overview=full&geometries=geojson',
    );

    final res = await http.get(url);
    final data = jsonDecode(res.body);

    if (data['routes'] == null || data['routes'].isEmpty) {
      throw Exception("No route found");
    }

    return RoutesResponse.fromJson(data['routes'][0]);
  }
}
