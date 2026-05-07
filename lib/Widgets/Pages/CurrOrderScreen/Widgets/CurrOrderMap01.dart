import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:scrapper/Models/Orders/Order01.dart';
import 'package:scrapper/Services/GeoLocatorService/GeoLocator03.dart';

import '../../../../../theme/theme_extensions.dart';

class CurrOrderMap01 extends StatelessWidget {
  final Order01 order;
  final MapController _mapController;
  final VoidCallback onMapReady, onGesture;
  final GeoLocator03 geoLocator;

  const CurrOrderMap01({
    super.key,
    required this.order,
    required MapController mapController,
    required this.onMapReady,
    required this.onGesture, required this.geoLocator,
  }) : _mapController = mapController;

  @override
  Widget build(BuildContext context) {
    final tileUrl = "https://mt.google.com/vt/lyrs=m&x={x}&y={y}&z={z}";
    final packageName = "app.samrat079.scrapper_sanitarian";
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        onMapReady: onMapReady,
        initialCenter: geoLocator.currentLatLng ?? LatLng(0, 0),
        initialZoom: 16,
        onPositionChanged: (position, hasGesture) {
          if (hasGesture) onGesture();
        }
      ),
      children: [
        /// The tile
        TileLayer(urlTemplate: tileUrl, userAgentPackageName: packageName),

        /// Destination
        MarkerLayer(
          markers: [
            /// Destination marker
            Marker(
              point: order.destination,
              child: Icon(
                Icons.location_on_outlined,
                color: context.colorScheme.secondary,
                size: 54,
              ),
            ),
          ],
        ),

        /// This is the curr location marker and uses
        /// the geolocator streams
        CurrentLocationLayer(
          positionStream: geoLocator.locationPositionStream,
          headingStream: geoLocator.locationHeadingStream,
        ),

        /// Polylines
        if (order.routesRes.coordinates.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: order.routesRes.coordinates,
                strokeWidth: 4,
                color: Colors.black,
              ),
            ],
          ),
      ],
    );
  }
}
