import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:nominatim_flutter/model/response/nominatim_response.dart';
import 'package:scrapper/Services/NominatimServices/NominatimServices01.dart';

class GeoLocator01 {
  /// Have to go for singleton
  static final GeoLocator01 _instance = GeoLocator01._internal();

  GeoLocator01._internal();

  factory GeoLocator01() => _instance;

  /// Listenable values
  final ValueNotifier<Position?> currPos = ValueNotifier<Position?>(null);
  final ValueNotifier<NominatimResponse?> currAdd =
      ValueNotifier<NominatimResponse?>(null);

  /// Function to check permissions called on init
  Future<void> checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
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

  /// Init calls the listeners
  Future<void> init() async {
    checkPermission();
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) => currPos.value = position);
  }

  Future<NominatimResponse?> getCurrAddress() =>
      NominatimServices01().searchByLatLng(
        LatLng(currPos.value?.latitude ?? 0.0, currPos.value?.longitude ?? 0.0),
      );

  LatLng getCurrLatLng() =>
      LatLng(currPos.value!.latitude, currPos.value!.longitude);
}
