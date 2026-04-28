import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:rxdart/rxdart.dart';

class GeoLocator02 extends ValueNotifier<LocationData?> {
  static final GeoLocator02 _instance = GeoLocator02._internal();

  GeoLocator02._internal() : super(null);

  factory GeoLocator02() => _instance;

  final Location _location = Location();

  late final Stream<LocationData> positionStream;
  late final Stream<LocationMarkerPosition> locationPositionStream;
  late final Stream<LocationMarkerHeading> locationHeadingStream;

  Future<void> init() async {
    final hasPermission = await _checkPermission();
    if (!hasPermission) return;

    /// Configure settings
    await _location.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 1000, // ms
      distanceFilter: 5,
    );

    final stream = _location.onLocationChanged.share();

    positionStream = stream;

    locationPositionStream = stream.map(
      (data) => LocationMarkerPosition(
        latitude: data.latitude ?? 0,
        longitude: data.longitude ?? 0,
        accuracy: data.accuracy ?? 0,
      ),
    );

    locationHeadingStream = stream.map(
      (data) => LocationMarkerHeading(
        heading: ((data.heading ?? 0) + 180) * (3.1415926535 / 180),
        accuracy: data.accuracy ?? 0,
      ),
    );

    stream.listen((pos) => value = pos);
  }

  Future<bool> _checkPermission() async {
    bool serviceEnabled = await _location.serviceEnabled();

    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService(); // 👈 popup
      if (!serviceEnabled) return false;
    }

    PermissionStatus permission = await _location.hasPermission();

    if (permission == PermissionStatus.denied) {
      permission = await _location.requestPermission();
      if (permission != PermissionStatus.granted) return false;
    }

    return true;
  }

  void updateCurrLocation(String uid) {
    positionStream.throttleTime(const Duration(seconds: 10)).listen((data) {
      FirebaseFirestore.instance.collection('sanitarians').doc(uid).update({
        'currLocation': GeoPoint(data.latitude ?? 0, data.longitude ?? 0),
      });
    });
  }

  LatLng? getCurrLatLng() {
    final pos = value;
    if (pos == null) return null;
    return LatLng(pos.latitude ?? 0, pos.longitude ?? 0);
  }
}
