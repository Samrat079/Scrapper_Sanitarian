import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:scrapper/Services/GeoLocatorService/GeoLocator01.dart';
import 'package:scrapper/Services/OSRMServices/OSRMService01.dart';
import 'package:scrapper/Services/OrderServices/CurrOrderService01.dart';
import 'package:scrapper/Widgets/Custome/CenterColumn/CenterColumn04.dart';
import 'package:scrapper/Widgets/Custome/Drawers/Drawer01.dart';
import 'package:scrapper/theme/theme_extensions.dart';

class CurrOrderScreen01 extends StatefulWidget {
  const CurrOrderScreen01({super.key});

  @override
  State<CurrOrderScreen01> createState() => _CurrOrderScreen01State();
}

class _CurrOrderScreen01State extends State<CurrOrderScreen01> {
  final service = CurrOrderService01();
  final _mapController = MapController();
  List<LatLng> routePoints = [];
  bool isLoadingRoute = true;

  StreamSubscription? _locSub;
  StreamSubscription? _locCameraSub;
  LatLng? _lastFetched;
  final currPosStream = GeoLocator01().positionStream;

  @override
  void initState() {
    super.initState();
    _initRoute();
    _listenToLocation();
    updateCamera();
  }

  void updateCamera() {
    _locCameraSub = currPosStream.listen(
      (data) => _mapController.move(data, 16),
    );
  }

  Future<void> _initRoute() async {
    final order = service.value;

    if (order == null) return;

    final start = GeoLocator01().getCurrLatLng();
    if (start == null) return;
    final end = order.destination;

    setState(() => isLoadingRoute = true);

    final points = await OSRMService01().getRoutePolylineGeoJSON(start, end);

    if (!mounted) return;

    setState(() {
      routePoints = points;
      isLoadingRoute = false;
    });

    _lastFetched = start;
  }

  Future<void> _updateRoute(LatLng current, LatLng end) async {
    /// First time OR no route
    if (routePoints.isEmpty || _lastFetched == null) {
      await _fetchRoute(current, end);
      return;
    }

    /// Check deviation
    final deviation = service.distanceFromRoute(current, routePoints);

    if (deviation > 30) {
      await _fetchRoute(current, end);
      return;
    }

    /// Trim route
    final closestIndex = service.getClosestIndex(current, routePoints);

    if (closestIndex > 0) {
      setState(() {
        routePoints = routePoints.sublist(closestIndex);
      });
    }

    /// Throttle refresh
    final moved = Distance().as(LengthUnit.Meter, _lastFetched!, current);

    if (moved > 50) {
      await _fetchRoute(current, end);
    }
  }

  Future<void> _fetchRoute(LatLng start, LatLng end) async {
    final points = await OSRMService01().getRoutePolylineGeoJSON(start, end);

    if (!mounted) return;

    setState(() {
      routePoints = points;
    });

    _lastFetched = start;
  }

  void _listenToLocation() {
    _locSub = currPosStream.listen((current) async {
      final order = service.value;
      if (order == null) return;

      final end = order.destination;

      await _updateRoute(current, end);
    });
  }

  @override
  void dispose() {
    _locSub?.cancel();
    _locCameraSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = CurrOrderService01();
    return ValueListenableBuilder(
      valueListenable: service,
      builder: (context, order, _) => Scaffold(
        drawer: Drawer01(),
        appBar: AppBar(),
        body: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: GeoLocator01().getCurrLatLng() ?? LatLng(0, 0),
            initialZoom: 16,
          ),
          children: [
            /// The tile itself
            TileLayer(
              urlTemplate: "https://mt.google.com/vt/lyrs=m&x={x}&y={y}&z={z}",
              userAgentPackageName: "com.example.scrapper_sanitarian",
            ),

            /// Current location
            CurrentLocationLayer(),

            /// Destination
            MarkerLayer(
              markers: [
                Marker(
                  point: order!.destination,
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.location_on_outlined,
                    color: context.colorScheme.secondary,
                  ),
                ),
              ],
            ),

            /// Polylines
            if (routePoints.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routePoints,
                    strokeWidth: 4,
                    color: context.colorScheme.secondary,
                  ),
                ],
              ),
          ],
        ),

        bottomSheet: CenterColumn04(
          padding: context.paddingLG,
          children: [
            context.gapMD,
            Text(order.address.place.displayName.toString()),
            context.gapMD,
            Text(order.address.houseNo),
            context.gapMD,
            Text(order.customer.displayName),
            context.gapMD,
            ElevatedButton(
              onPressed: service.cancelCurrOrder,
              child: Text('Cancle'),
            ),
          ],
        ),
      ),
    );
  }
}
