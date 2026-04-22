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
import 'package:scrapper/Widgets/Custome/Intl/KmText01.dart';
import 'package:scrapper/Widgets/Custome/Intl/PriceText01.dart';
import 'package:scrapper/theme/theme_extensions.dart';

import '../../../Custome/CardList01/CardList01.dart';

class CurrOrderScreen01 extends StatefulWidget {
  const CurrOrderScreen01({super.key});

  @override
  State<CurrOrderScreen01> createState() => _CurrOrderScreen01State();
}

class _CurrOrderScreen01State extends State<CurrOrderScreen01> {
  /// Looks like it is not easy to make this simpler
  /// any simpler and we loose stuff, also to make it
  /// better we have to make a nav engine, which i dont
  /// want to do as of now
  final service = CurrOrderService01();
  final _mapController = MapController();
  List<LatLng> routePoints = [];

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

    final points = await OSRMService01().getRoutePolylineGeoJSON(start, end);

    if (!mounted) return;

    setState(() => routePoints = points);

    _lastFetched = start;
  }

  Future<void> _updateRoute(LatLng current, LatLng end) async {
    final shouldFetch =
        routePoints.isEmpty ||
        _lastFetched == null ||
        CurrOrderService01().distanceFromRoute(current, routePoints) > 30 ||
        Distance().as(LengthUnit.Meter, _lastFetched!, current) > 50;

    if (shouldFetch) {
      await _fetchRoute(current, end);
      return;
    }

    final closestIndex = CurrOrderService01().getClosestIndex(
      current,
      routePoints,
    );

    if (closestIndex > 0) {
      setState(() => routePoints = routePoints.sublist(closestIndex));
    }
  }

  Future<void> _fetchRoute(LatLng start, LatLng end) async {
    final points = await OSRMService01().getRoutePolylineGeoJSON(start, end);
    if (!mounted) return;
    setState(() => routePoints = points);
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
    return ValueListenableBuilder(
      valueListenable: service,
      builder: (context, order, _) => Scaffold(
        drawer: Drawer01(),
        appBar: AppBar(),
        body: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: GeoLocator01().getCurrLatLng() ?? LatLng(0, 0),
                initialZoom: 16,
              ),
              children: [
                /// The tile itself
                TileLayer(
                  urlTemplate:
                      "https://mt.google.com/vt/lyrs=m&x={x}&y={y}&z={z}",
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

            DraggableScrollableSheet(
              initialChildSize: 0.25,
              maxChildSize: 0.80,
              minChildSize: 0.20,
              snap: true,
              snapSizes: [0.6],
              builder: (context, scrollController) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  color: context.colorScheme.surfaceContainer,
                ),
                child: CenterColumn04(
                  padding: context.paddingSM,
                  scrollController: scrollController,
                  children: [

                    /// Location card
                    CardList01(
                      children: [
                        ListTile(
                          contentPadding: context.paddingSM,
                          leading: const Icon(Icons.location_pin),
                          title: Text(order.address.place.name!),
                          subtitle: Text(order.address.place.displayName!),
                        ),
                        ListTile(
                          contentPadding: context.paddingSM,
                          leading: const Icon(Icons.house_outlined),
                          title: const Text("House No"),
                          subtitle: Text(order.address.houseNo),
                        ),
                      ],
                    ),

                    /// Customer card
                    CardList01(
                      children: [
                        ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person_2_outlined),
                          ),
                          title: Text(order.customer.displayName),
                          trailing: const Icon(Icons.call),
                        ),
                      ],
                    ),

                    /// price distance
                    CardList01(
                      children: [
                        ListTile(
                          title: PriceText01(price: order.price),
                          subtitle: KmText01(
                            meters: order.distance!.toDouble(),
                          ),
                        ),
                      ],
                    ),

                    context.gapMD,

                    /// Cancel
                    ElevatedButton(
                      onPressed: service.cancelCurrOrder,
                      child: const Text('Cancel Order'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
