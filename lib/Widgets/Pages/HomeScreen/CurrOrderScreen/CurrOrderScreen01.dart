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
  List<LatLng> routePoints = [];
  bool isLoadingRoute = true;

  StreamSubscription? _locSub;
  LatLng? _lastFetched;

  @override
  void initState() {
    super.initState();
    _initRoute(); // 👈 ADD THIS
    _listenToLocation();
  }

  Future<void> _initRoute() async {
    final service = CurrOrderService01();
    final order = service.value;

    if (order == null) return;

    final start = GeoLocator01().getCurrLatLng();
    final end = service.latLngFromPlace(order.address.place);

    setState(() => isLoadingRoute = true);

    final points = await OSRMService01().getRoutePolylineGeoJSON(start, end);

    if (!mounted) return;

    setState(() {
      routePoints = points;
      isLoadingRoute = false;
    });

    _lastFetched = start;
  }

  void _listenToLocation() {
    final service = CurrOrderService01();

    _locSub = GeoLocator01().positionStream.listen((current) async {
      final order = service.value;
      if (order == null) return;

      final end = service.latLngFromPlace(order.address.place);

      /// First time → fetch route
      if (routePoints.isEmpty) {
        final points = await OSRMService01().getRoutePolylineGeoJSON(
          current,
          end,
        );

        if (!mounted) return;

        setState(() {
          routePoints = points;
        });

        _lastFetched = current;
        return;
      }

      /// 🧠 Check how far user is from route
      final deviation = _distanceFromRoute(current);

      /// 🚨 If user is OFF route → refetch
      if (deviation > 30) {
        final points = await OSRMService01().getRoutePolylineGeoJSON(
          current,
          end,
        );

        if (!mounted) return;

        setState(() {
          routePoints = points;
        });

        _lastFetched = current;
        return;
      }

      /// ✅ User is ON route → just trim
      final closestIndex = _getClosestIndex(current);

      if (closestIndex > 0) {
        setState(() {
          routePoints = routePoints.sublist(closestIndex);
        });
      }

      /// 🚨 Optional throttle for full refresh
      if (_lastFetched != null) {
        final moved = Distance().as(LengthUnit.Meter, _lastFetched!, current);

        if (moved > 50) {
          final points = await OSRMService01().getRoutePolylineGeoJSON(
            current,
            end,
          );

          if (!mounted) return;

          setState(() {
            routePoints = points;
          });

          _lastFetched = current;
        }
      } else {
        _lastFetched = current;
      }
    });
  }

  int _getClosestIndex(LatLng current) {
    double minDist = double.infinity;
    int closestIndex = 0;

    for (int i = 0; i < routePoints.length; i++) {
      final dist = Distance().as(LengthUnit.Meter, current, routePoints[i]);

      if (dist < minDist) {
        minDist = dist;
        closestIndex = i;
      }
    }

    return closestIndex;
  }

  double _distanceFromRoute(LatLng current) {
    double minDist = double.infinity;

    for (final point in routePoints) {
      final dist = Distance().as(LengthUnit.Meter, current, point);

      if (dist < minDist) {
        minDist = dist;
      }
    }

    return minDist;
  }

  @override
  void dispose() {
    _locSub?.cancel();
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
          options: MapOptions(
            initialCenter: GeoLocator01().getCurrLatLng(),
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
                  point: service.latLngFromPlace(order!.address.place),
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
