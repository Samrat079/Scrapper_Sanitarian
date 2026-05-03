import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:rxdart/rxdart.dart';

class GeoLocator03 extends ChangeNotifier {
  GeoLocator03();

  final Location _location = Location();

  Stream<LocationData>? _positionStreamSub;
  StreamSubscription<LocationData>? _listener;

  LocationData? _current;

  LocationData? get current => _current;

  LatLng? get currentLatLng {
    if (_current == null) return null;
    return LatLng(_current!.latitude!, _current!.longitude!);
  }

  Future<void> init() async {
    final hasPermission = await _checkPermission();
    if (!hasPermission) return;

    await _location.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 1000,
      distanceFilter: 5,
    );

    final stream = _location.onLocationChanged.share();

    _listener?.cancel();
    _listener = stream.listen((pos) {
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
