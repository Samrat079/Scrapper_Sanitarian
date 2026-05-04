import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';

class GeoLocator03 extends ChangeNotifier {
  /// Constructor, this is made to not need init
  GeoLocator03() {
    _init();
  }

  /// Location package
  final Location _location = Location();

  /// Curr location
  LocationData? _current;

  LocationData? get current => _current;
  StreamSubscription<LocationData>? _listener;

  /// If a single value is needed use this
  LatLng? get currentLatLng {
    final lat = _current?.latitude;
    final lng = _current?.longitude;
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  /// base stream
  Stream<LocationData> get _rawStream =>
      _location.onLocationChanged.asBroadcastStream();

  /// ---------------- POSITION STREAM ----------------
  Stream<LocationMarkerPosition> get locationPositionStream => _rawStream.map(
    (data) => LocationMarkerPosition(
      latitude: data.latitude ?? 0,
      longitude: data.longitude ?? 0,
      accuracy: data.accuracy ?? 0,
    ),
  );

  /// ---------------- HEADING STREAM ----------------
  Stream<LocationMarkerHeading> get locationHeadingStream => _rawStream.map(
    (data) => LocationMarkerHeading(
      heading: ((data.heading ?? 0) + 180) * (pi / 180),
      accuracy: data.accuracy ?? 0,
    ),
  );

  bool _initialized = false;

  Future<void> _init() async {
    if (_initialized) return;
    _initialized = true;

    final hasPermission = await _checkPermission();
    if (!hasPermission) return;

    await _location.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 0,
      distanceFilter: 0,
    );

    _listener?.cancel();

    _listener = _rawStream.listen((pos) {
      _current = pos;
      notifyListeners();
    });
  }

  Future<bool> _checkPermission() async {
    bool serviceEnabled = await _location.serviceEnabled();

    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return false;
    }

    PermissionStatus permission = await _location.hasPermission();

    if (permission == PermissionStatus.denied) {
      permission = await _location.requestPermission();
      if (permission != PermissionStatus.granted) return false;
    }

    return true;
  }

  @override
  void dispose() {
    _listener?.cancel();
    super.dispose();
  }
}
