import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' hide LocationAccuracy;
import 'package:nominatim_flutter/model/response/nominatim_response.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scrapper/Services/AppUserServices/AppUserService02.dart';
import 'package:scrapper/Services/OrderServices/CurrOrderService01.dart';

import '../NominatimServices/NominatimServices01.dart';

class GeoLocator01 extends ValueNotifier<Position?> {
  /// Have to go for singleton
  static final GeoLocator01 _instance = GeoLocator01._internal();

  GeoLocator01._internal() : super(null);

  factory GeoLocator01() => _instance;

  /// Listenable values for some reason all of them
  /// are late, might need to change later
  late final Stream<Position> positionStream;
  late final Stream<LocationMarkerPosition> locationPositionStream;
  late final Stream<LocationMarkerHeading> locationHeadingStream;
  late final StreamSubscription<ServiceStatus> serviceStatusStream;

  /// Init calls the listeners
  Future<void> init() async {
    /// For checking permissions
    // await checkPermission();
    await checkPermission02();

    /// Keep this under 10 as we are handling
    /// api throttling from maps
    final stream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        distanceFilter: 5,
        accuracy: LocationAccuracy.high,
      ),
    ).share();

    /// the normal stream
    positionStream = stream;

    /// the position stream for location marker
    locationPositionStream = stream.map(
      (data) => LocationMarkerPosition(
        latitude: data.latitude,
        longitude: data.longitude,
        accuracy: data.accuracy,
      ),
    );

    /// the heading stream for location marker
    locationHeadingStream = stream.map(
      (data) => LocationMarkerHeading(
        heading: degToRadian(data.heading + 180),
        accuracy: data.accuracy,
      ),
    );

    /// This updates the valueNotifier
    stream.listen((pos) => value = pos);
  }

  void updateCurrLocation(String uid) {
    final stream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        distanceFilter: 1000,
        accuracy: LocationAccuracy.high,
      ),
    );

    stream
        .throttleTime(Duration(seconds: 10))
        .listen(
          (data) => FirebaseFirestore.instance
              .collection('sanitarians')
              .doc(uid)
              .update({
                'currLocation': GeoPoint(data.latitude, data.longitude),
              }),
        );
  }

  LatLng? getCurrLatLng() {
    final pos = value;
    if (pos == null) return null;
    return LatLng(pos.latitude, pos.longitude);
  }

  /// Function to check permissions called on init
  // Future<void> checkPermission() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;
  //
  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       return Future.error('Location permissions are denied');
  //     }
  //   }
  //   if (permission == LocationPermission.deniedForever) {
  //     return Future.error(
  //       'Location permissions are permanently denied, cannot request.',
  //     );
  //   }
  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     Geolocator.openLocationSettings();
  //     return Future.error('Location services are disabled.');
  //   }
  // }

  Future<bool> checkPermission02() async {
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return false;
    }

    final location = Location();
    bool serviceEnabled = await location.serviceEnabled();

    if (!serviceEnabled) {
      /// This shows the native location popup
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return false;
    }

    return true;
  }
}
