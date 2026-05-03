import 'package:flutter/material.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';
import 'package:scrapper/Services/OrderServices/OrderService03.dart';
import 'package:scrapper/Widgets/Custome/CenterColumn/CenterColumn04.dart';
import 'package:scrapper/Widgets/Custome/Drawers/Drawer01.dart';
import 'package:scrapper/Widgets/Pages/CurrOrderScreen/Widgets/OrderCompleteSheet01.dart';
import 'package:scrapper/Widgets/Pages/CurrOrderScreen/Widgets/OrderOtpSheet01.dart';
import 'package:scrapper/theme/theme_extensions.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../Services/GeoLocatorService/GeoLocator02.dart';
import 'Widgets/CurrOrderSheet01.dart';
import 'Widgets/CurrOrderMap01.dart';

class CurrOrderScreen02 extends StatefulWidget {
  final String orderId;

  const CurrOrderScreen02({super.key, required this.orderId});

  @override
  State<CurrOrderScreen02> createState() => _CurrOrderScreen02State();
}

/// was able to make this simpler check currorderservice to know more
class _CurrOrderScreen02State extends State<CurrOrderScreen02>
    with TickerProviderStateMixin {
  final currOrder = OrderService03();

  /// Animation controller
  late final AnimatedMapController _animatedMapController;

  /// Tile Layer
  final tileUrl = "https://mt.google.com/vt/lyrs=m&x={x}&y={y}&z={z}";
  final packageName = "com.example.scrapper_sanitarian";

  /// Global key
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  /// Variables
  bool reCentered = true;

  /// Order step
  OrderStep orderStep = OrderStep.accept;

  /// Geolocator
  final geo = GeoLocator02();

  // ✅ Proper listener method (no anonymous function)
  void _onLocationUpdate() {
    if (!mounted) return;

    final loc = geo.value;
    if (loc == null || !reCentered) return;

    final latLng = LatLng(loc.latitude ?? 0, loc.longitude ?? 0);
    final double rotation = 360 - (loc.heading ?? 0);
    const zoom = 18.0;

    _animatedMapController.animateTo(
      dest: latLng,
      zoom: zoom,
      rotation: rotation,
    );
  }

  /// The geolocation has to be listened
  /// and disposed or else will have problem
  @override
  void initState() {
    super.initState();

    _animatedMapController = AnimatedMapController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
      cancelPreviousAnimations: true,
    );

    geo.addListener(_onLocationUpdate);
  }

  @override
  void dispose() {
    geo.removeListener(_onLocationUpdate);
    _animatedMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: currOrder,
      builder: (context, order, _) {
        /// Loading state
        if (order == null) {
          return Scaffold(
            appBar: AppBar(),
            body: CenterColumn04(
              centerVertically: true,
              children: [
                LinearProgressIndicator(),
                Text('Looking for the best route'),
              ],
            ),
          );
        }

        /// Loaded state
        return Scaffold(
          drawer: Drawer01(),
          key: _scaffoldKey,
          extendBodyBehindAppBar: true,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.miniStartTop,

          /// The appbar as if a floating button
          /// opens the drawer but needs a scaffold key
          floatingActionButton: Column(
            children: [
              FloatingActionButton(
                onPressed: () => _scaffoldKey.currentState!.openDrawer(),
                backgroundColor: context.colorScheme.surface,
                foregroundColor: context.colorScheme.onSurface,
                child: Icon(Icons.menu_rounded),
              ),
              context.gapMD,

              /// Try to simplify the state in this
              FloatingActionButton(
                onPressed: () => setState(() => reCentered = true),
                backgroundColor: context.colorScheme.surface,
                foregroundColor: reCentered
                    ? context.colorScheme.primary
                    : context.colorScheme.onSurface,
                child: Icon(Icons.route_outlined),
              ),
            ],
          ),

          body: SlidingUpPanel(
            ///  widget for the maps, needs to be stateful else flicker
            body: CurrOrderMap01(
              order: order,
              mapController: _animatedMapController.mapController,
              onMapReady: () {},
              onGesture: () => setState(() => reCentered = false),
            ),

            /// Bottom sheet and its options
            parallaxEnabled: true,
            backdropTapClosesPanel: true,
            parallaxOffset: 0.3,
            borderRadius: BorderRadius.vertical(top: context.radiusXL.topLeft),
            color: context.colorScheme.surface,
            panelBuilder: (ScrollController controller) {
              /// This is a complex switch will need
              /// to change this in future
              switch (orderStep) {
                case OrderStep.accept:
                  return OrderAcceptSheet01(
                    order: order,
                    controller: controller,
                    onCancel: currOrder.cancelCurrOrder,
                    onComplete: () => setState(() => orderStep = OrderStep.otp),
                  );

                case OrderStep.otp:
                  return OrderOtpSheet01(
                    order: order,
                    controller: controller,
                    onGoBack: () =>
                        setState(() => orderStep = OrderStep.accept),
                    onSubmit: (data) => currOrder.completeOrder().then(
                      (_) => setState(() => orderStep = OrderStep.complete),
                    ),
                  );

                case OrderStep.complete:
                  return OrderCompleteSheet01(
                    order: order,
                    controller: controller,
                    onComplete: () => currOrder.stop(),
                  );
              }
            },
          ),
        );
      },
    );
  }
}

/// Order step enum
enum OrderStep { accept, otp, complete }
