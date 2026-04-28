import 'dart:async';

import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:scrapper/Services/MapLauncher/MapLauncher.dart';
import 'package:scrapper/Services/OSRMServices/OSRMService01.dart';
import 'package:scrapper/Widgets/Custome/CenterColumn/CenterColumn04.dart';
import 'package:scrapper/Widgets/Custome/Drawers/Drawer01.dart';
import 'package:scrapper/Widgets/Custome/Intl/PriceText01.dart';
import 'package:scrapper/theme/theme_extensions.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../../Models/RouteResponse/RouteResponse.dart';
import '../../../Services/GeoLocatorService/GeoLocator02.dart';
import '../../../Services/OrderServices/CurrOrderService02.dart';
import 'Widgets/CurrOrderBottomSheet01.dart';
import 'Widgets/CurrOrderMap01.dart';

class CurrOrderScreen02 extends StatefulWidget {
  const CurrOrderScreen02({super.key});

  @override
  State<CurrOrderScreen02> createState() => _CurrOrderScreen02State();
}

class _CurrOrderScreen02State extends State<CurrOrderScreen02>
    with TickerProviderStateMixin {
  /// was able to make this simpler check currorderservice to know more

  /// Tile Layer
  final tileUrl = "https://mt.google.com/vt/lyrs=m&x={x}&y={y}&z={z}";
  final packageName = "com.example.scrapper_sanitarian";

  /// Global key
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  /// Moved on to animation controller which improved animations
  late final _animatedMapController = AnimatedMapController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeIn,
    cancelPreviousAnimations: true,
  );

  void updateCamera() => GeoLocator02().addListener(() {
    final loc = GeoLocator02().value;
    if (loc == null) return;

    final latLng = LatLng(loc.latitude ?? 0, loc.longitude ?? 0);

    _animatedMapController.animateTo(
      dest: latLng,
      zoom: 18,

      /// All other methods of normalising has
      /// failed
      rotation: 360 - (loc.heading ?? 0),
      duration: Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: CurrOrderService02(),
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

          /// The appbar as if a floating button
          /// opens the drawer but needs a scaffold key
          floatingActionButton: FloatingActionButton(
            onPressed: () => _scaffoldKey.currentState!.openDrawer(),
            backgroundColor: context.colorScheme.surface,
            foregroundColor: context.colorScheme.onSurface,
            child: Icon(Icons.menu_rounded),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.miniStartTop,

          drawer: Drawer01(),

          body: SlidingUpPanel(
            ///  widget for the maps, needs to be stateful else flicker
            body: CurrOrderMap01(
              order: order,
              mapController: _animatedMapController.mapController,
              onMapReady: updateCamera,
            ),

            /// Bottom sheet and its options
            parallaxEnabled: true,
            backdropTapClosesPanel: true,
            parallaxOffset: 0.3,
            borderRadius: BorderRadius.vertical(top: context.radiusXL.topLeft),
            color: context.colorScheme.surface,
            panelBuilder: (ScrollController controller) =>
                OrderAcceptBottomSheet01(order: order, controller: controller),
          ),
        );
      },
    );
  }
}
