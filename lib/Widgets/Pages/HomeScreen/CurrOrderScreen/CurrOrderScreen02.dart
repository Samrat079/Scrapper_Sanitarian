import 'dart:async';

import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:scrapper/Services/GeoLocatorService/GeoLocator01.dart';
import 'package:scrapper/Services/MapLauncher/MapLauncher.dart';
import 'package:scrapper/Services/OSRMServices/OSRMService01.dart';
import 'package:scrapper/Services/OrderServices/CurrOrderService01.dart';
import 'package:scrapper/Widgets/Custome/CenterColumn/CenterColumn04.dart';
import 'package:scrapper/Widgets/Custome/Drawers/Drawer01.dart';
import 'package:scrapper/Widgets/Custome/Intl/PriceText01.dart';
import 'package:scrapper/Widgets/Pages/HomeScreen/CurrOrderScreen/Widgets/CurrOrderBottomSheet01.dart';
import 'package:scrapper/theme/theme_extensions.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../../Models/RouteResponse/RouteResponse.dart';
import '../../../Custome/CardList01/CardList01.dart';

class CurrOrderScreen02 extends StatefulWidget {
  const CurrOrderScreen02({super.key});

  @override
  State<CurrOrderScreen02> createState() => _CurrOrderScreen02State();
}

class _CurrOrderScreen02State extends State<CurrOrderScreen02> {
  /// Looks like it is not easy to make this simpler
  /// any simpler and we loose stuff, also to make it
  /// better we have to make a nav engine, which i dont
  /// want to do as of now

  /// Tile Layer
  final tileUrl = "https://mt.google.com/vt/lyrs=m&x={x}&y={y}&z={z}";
  final packageName = "com.example.scrapper_sanitarian";

  /// Services
  final _mapController = MapController();

  /// Subscriptions find dispose below
  StreamSubscription? _locCameraSub;
  final currPosStream = GeoLocator01().positionStream;

  /// Global key
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    updateCamera();
  }

  void updateCamera() {
    _locCameraSub = currPosStream.listen((data) {
      _mapController.move(LatLng(data.latitude, data.longitude), 16);
      if (data.heading != null && data.heading! > 0) {
        _mapController.rotateAroundPoint(data.heading);
      }
    });
  }

  @override
  void dispose() {
    _locCameraSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: CurrOrderService01(),
      builder: (context, order, _) {
        if (order == null) {
          return Scaffold(
            appBar: AppBar(),
            body: CenterColumn04(
              children: [
                LinearProgressIndicator(),
                Text('Looking for the best route'),
              ],
            ),
          );
        }
        return Scaffold(
          key: _scaffoldKey,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            leading: IconButton.filled(
              onPressed: () => _scaffoldKey.currentState!.openDrawer(),
              icon: Icon(Icons.menu_outlined),
              style: IconButton.styleFrom(
                backgroundColor: context.colorScheme.surface,
              ),
            ),
          ),
          drawer: Drawer01(),

          body: SlidingUpPanel(
            body: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: GeoLocator01().getCurrLatLng() ?? LatLng(0, 0),
                initialZoom: 16,
              ),
              children: [
                /// The tile itself
                TileLayer(
                  urlTemplate: tileUrl,
                  userAgentPackageName: packageName,
                ),

                /// Current location
                CurrentLocationLayer(),

                /// Destination
                MarkerLayer(
                  markers: [
                    Marker(
                      point: order.destination,
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
                if (order.routesRes.coordinates.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: order.routesRes.coordinates,
                        strokeWidth: 4,
                        color: context.colorScheme.primary,
                      ),
                    ],
                  ),
              ],
            ),

            /// Bottom sheet options
            parallaxEnabled: true,
            borderRadius: BorderRadius.vertical(top: context.radiusMD.topLeft),
            color: context.colorScheme.surface,
            panelBuilder: (ScrollController controller) =>
                CurrOrderBottomSheet01(order: order, controller: controller),
          ),
        );
      },
    );
  }
}
