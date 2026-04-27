import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:scrapper/Models/Orders/Order01.dart';

import '../../../../../Services/GeoLocatorService/GeoLocator01.dart';
import '../../../../../theme/theme_extensions.dart';

class CurrOrderMap01 extends StatefulWidget {
  final Order01 order;
  final MapController _mapController;
  final VoidCallback onMapReady;

  const CurrOrderMap01({
    super.key,
    required this.order,
    required MapController mapController,
    required this.onMapReady,
  }) : _mapController = mapController;

  @override
  State<CurrOrderMap01> createState() => _CurrOrderMap01State();
}

class _CurrOrderMap01State extends State<CurrOrderMap01> {
  @override
  Widget build(BuildContext context) {
    final tileUrl = "https://mt.google.com/vt/lyrs=m&x={x}&y={y}&z={z}";
    final packageName = "com.example.scrapper_sanitarian";
    return FlutterMap(
      mapController: widget._mapController,
      options: MapOptions(
        onMapReady: widget.onMapReady,
        initialCenter: GeoLocator01().getCurrLatLng() ?? LatLng(0, 0),
        initialZoom: 16,
      ),
      children: [
        /// The tile
        TileLayer(urlTemplate: tileUrl, userAgentPackageName: packageName),

        /// Destination
        MarkerLayer(
          markers: [
            Marker(
              point: widget.order.destination,
              child: Icon(
                Icons.location_on_outlined,
                color: context.colorScheme.secondary,
                size: 54,
              ),
            ),
            Marker(
              point: GeoLocator01().getCurrLatLng() ?? LatLng(0, 0),
              child: Icon(
                Icons.car_rental_outlined,
                color: context.colorScheme.surface,
                size: 54,
              ),
            ),
          ],
        ),

        /// Polylines
        if (widget.order.routesRes.coordinates.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: widget.order.routesRes.coordinates,
                strokeWidth: 4,
                color: context.colorScheme.surface,
              ),
            ],
          ),
      ],
    );
  }
}
