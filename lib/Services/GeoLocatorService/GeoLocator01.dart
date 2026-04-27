import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:nominatim_flutter/model/response/nominatim_response.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scrapper/Services/AppUserServices/AppUserService02.dart';
import 'package:scrapper/Services/OrderServices/CurrOrderService01.dart';

class GeoLocator01 extends ValueNotifier<Position?> {
  /// Have to go for singleton
  static final GeoLocator01 _instance = GeoLocator01._internal();

  GeoLocator01._internal() : super(null);

  factory GeoLocator01() => _instance;

  /// Listenable values
  late final Stream<Position> positionStream;

  /// Init calls the listeners
  Future<void> init() async {
    await checkPermission();
    final stream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(distanceFilter: 50),
    );
    positionStream = stream;
    updateCurrLocation();
    stream.listen((pos) {
      value = pos;
    });
  }

  void updateCurrLocation() {
    final stream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(distanceFilter: 1000),
    );

    stream
        .throttleTime(Duration(seconds: 5))
        .listen(
          (data) => FirebaseFirestore.instance
              .collection('sanitarians')
              .doc(AppUserService02().current.uid)
              .update({
                'currLocation': GeoPoint(data.latitude, data.longitude),
              }),
        );
  }

  double calDistance(List<LatLng> coordinates) {
    final path = Path.from(coordinates);

    return path.distance;
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
