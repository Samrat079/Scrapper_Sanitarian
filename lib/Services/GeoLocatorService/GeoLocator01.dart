import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
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
  late final Stream<String> locationLabelStream;
  late final Stream<ServiceStatus> serviceStatusStream;
  late final Stream<LocationPermission> permissionStream;

  /// Init calls the listeners
  Future<void> init() async {
    /// For checking permissions
    await checkPermission();
    serviceStatusStream = Geolocator.getServiceStatusStream()
        .startWith(
          await Geolocator.isLocationServiceEnabled()
              ? ServiceStatus.enabled
              : ServiceStatus.disabled,
        )
        .shareReplay(maxSize: 1);

    permissionStream = Stream.fromFuture(
      Geolocator.checkPermission(),
    ).asBroadcastStream().shareReplay(maxSize: 1);

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

    /// THis is a stream for the current location name stream
    /// consider switching to nominatim response as it returns that
    /// or make a customer place class

    locationLabelStream = positionStream
        .switchMap((pos) async* {
          // GPS check
          if (!await Geolocator.isLocationServiceEnabled()) {
            yield "GPS is turned OFF";
            return;
          }

          // Permission check
          var permission = await Geolocator.checkPermission();

          if (permission == LocationPermission.denied) {
            yield "Location permission denied";
            return;
          }

          if (permission == LocationPermission.deniedForever) {
            yield "Permission permanently denied";
            return;
          }

          yield "Fetching place...";

          try {
            final place = await NominatimServices01().searchByLatLng(
              LatLng(pos.latitude, pos.longitude),
            );
            yield place.name ?? "Unknown location";
          } catch (_) {
            yield "Error fetching location";
          }
        })
        .shareReplay(maxSize: 1);
  }

  void updateCurrLocation(String uid) {
    final stream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
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
  Future<void> checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, cannot request.',
      );
    }
  }
}
