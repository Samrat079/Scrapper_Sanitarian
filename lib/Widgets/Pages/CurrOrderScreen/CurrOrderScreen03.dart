import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:http/http.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../Services/GeoLocatorService/GeoLocator03.dart';
import '../../../Services/OrderServices/OrderService04.dart';
import '../../../theme/theme_extensions.dart';
import '../../Custome/CenterColumn/CenterColumn04.dart';
import '../../Custome/Drawers/Drawer01.dart';
import 'Widgets/CurrOrderMap01.dart';
import 'Widgets/CurrOrderSheet01.dart';
import 'Widgets/OrderCompleteSheet01.dart';
import 'Widgets/OrderOtpSheet01.dart';

class CurrOrderScreen03 extends StatefulWidget {
  const CurrOrderScreen03({super.key});

  @override
  State<CurrOrderScreen03> createState() => _CurrOrderScreen03State();
}

class _CurrOrderScreen03State extends State<CurrOrderScreen03>
    with TickerProviderStateMixin {
  GeoLocator03? _geo;

  late final AnimatedMapController _animatedMapController;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  bool reCentered = true;
  OrderStep orderStep = OrderStep.accept;

  /// ------------------ LOCATION LISTENER ------------------
  void _onLocationUpdate() {
    if (!mounted) return;

    final loc = _geo?.current;
    if (loc == null || !reCentered) return;

    final latLng = LatLng(loc.latitude ?? 0, loc.longitude ?? 0);
    final double rotation = 360 - (loc.heading ?? 0);

    _animatedMapController.animateTo(
      dest: latLng,
      zoom: 18,
      rotation: rotation,
    );
  }

  /// ------------------ INIT ------------------
  @override
  void initState() {
    super.initState();

    _animatedMapController = AnimatedMapController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
      cancelPreviousAnimations: true,
    );
  }

  /// ------------------ DEPENDENCIES ------------------
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final newGeo = context.read<GeoLocator03>();

    if (_geo != newGeo) {
      _geo?.removeListener(_onLocationUpdate);
      _geo = newGeo;
      _geo!.addListener(_onLocationUpdate);
    }
  }

  /// ------------------ DISPOSE ------------------
  @override
  void dispose() {
    _geo?.removeListener(_onLocationUpdate);
    _animatedMapController.dispose();
    super.dispose();
  }

  /// ------------------ UI ------------------
  @override
  Widget build(BuildContext context) {
    final currOrderService = context.watch<OrderService04>();
    final order = currOrderService.order;

    /// ------------------ LOADING ------------------
    if (order == null) {
      return Scaffold(
        appBar: AppBar(),
        body: CenterColumn04(
          centerVertically: true,
          children: const [
            LinearProgressIndicator(),
            Text('Looking for the best route'),
          ],
        ),
      );
    }

    /// ------------------ MAIN UI ------------------
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer01(),
      extendBodyBehindAppBar: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,

      /// Floating buttons
      floatingActionButton: Column(
        children: [
          FloatingActionButton(
            heroTag: null,
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            backgroundColor: context.colorScheme.surface,
            foregroundColor: context.colorScheme.onSurface,
            child: const Icon(Icons.menu_rounded),
          ),

          context.gapMD,

          FloatingActionButton(
            heroTag: null,
            onPressed: () => setState(() => reCentered = true),
            backgroundColor: context.colorScheme.surface,
            foregroundColor: reCentered
                ? context.colorScheme.primary
                : context.colorScheme.onSurface,
            child: const Icon(Icons.route_outlined),
          ),
        ],
      ),

      body: SlidingUpPanel(
        /// ------------------ MAP ------------------
        body: CurrOrderMap01(
          order: order,
          mapController: _animatedMapController.mapController,
          onMapReady: () {},
          onGesture: () => setState(() => reCentered = false),
          geoLocator: _geo!,
        ),

        /// ------------------ PANEL ------------------
        parallaxEnabled: true,
        backdropTapClosesPanel: true,
        parallaxOffset: 0.3,
        borderRadius: BorderRadius.vertical(top: context.radiusXL.topLeft),
        color: context.colorScheme.surface,

        panelBuilder: (ScrollController controller) {
          switch (orderStep) {
            case OrderStep.accept:
              return OrderAcceptSheet01(
                order: order,
                controller: controller,
                onCancel: () async {
                  await currOrderService.cancelCurrOrder();
                  currOrderService.stop();
                },
                onComplete: () => setState(() => orderStep = OrderStep.otp),
              );

            case OrderStep.otp:
              return OrderOtpSheet01(
                order: order,
                controller: controller,
                onGoBack: () => setState(() => orderStep = OrderStep.accept),
                onSubmit: (data) async {
                  await currOrderService.completeCurrOrder();
                  setState(() => orderStep = OrderStep.complete);
                },
              );

            case OrderStep.complete:
              return OrderCompleteSheet01(
                order: order,
                controller: controller,
                onComplete: () => currOrderService.stop(),
              );
          }
        },
      ),
    );
  }
}

/// Order step enum
enum OrderStep { accept, otp, complete }
