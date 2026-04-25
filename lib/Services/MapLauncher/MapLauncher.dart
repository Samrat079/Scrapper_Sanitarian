import 'package:latlong2/latlong.dart';
import 'package:map_launcher/map_launcher.dart';

class MapLaunch {
  void openMapTo(LatLng coordinates, String? name) async {
    await MapLauncher.showMarker(
      mapType: MapType.google,
      coords: Coords(coordinates.latitude, coordinates.longitude),
      title: name ?? coordinates.toString(),
    );
  }
}
