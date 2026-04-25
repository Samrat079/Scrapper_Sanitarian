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
  // final service = CurrOrderService01();
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
      _mapController.rotateAroundPoint(data.heading);
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
        if (order == null || order.routesRes.coordinates.isEmpty) {
          return Center(child: CircularProgressIndicator());
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
            maxHeight: MediaQuery.of(context).size.height * 0.6,
            borderRadius: BorderRadius.vertical(top: context.radiusMD.topLeft),
            color: context.colorScheme.surface,
            panelBuilder: (ScrollController controller) => CenterColumn04(
              padding: context.paddingSM,
              scrollController: controller,
              children: [
                /// bottom sheet header
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: ListTile(
                          leading: Icon(Icons.add_road),
                          title: Text('Distance'),
                          subtitle: Text(
                            '${(order.routesRes.distance / 1000).toStringAsFixed(2)} Km',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Card(
                        child: ListTile(
                          leading: Icon(Icons.timer_outlined),
                          title: Text('Time'),
                          subtitle: Text(
                            order.routesRes.duration.pretty(
                              abbreviated: true,
                              tersity: DurationTersity.minute,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(),

                /// Location card
                ListTile(
                  leading: const Icon(Icons.location_pin),
                  title: Text(order.address.place.name!),
                  subtitle: Text(order.address.place.displayName!),
                  trailing: IconButton(
                    onPressed: () => MapLaunch().openMapTo(
                      order.destination,
                      order.address.place.name,
                    ),
                    icon: const Icon(Icons.near_me_outlined),
                  ),
                ),
                Divider(),
                ListTile(
                  leading: const Icon(Icons.house_outlined),
                  title: Text(order.address.houseNo),
                ),

                Divider(),

                /// Customer card
                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person_2_outlined),
                  ),
                  title: Text(order.customer.displayName),
                  subtitle: Text(order.address.phoneNumber),
                  trailing: const Icon(Icons.call),
                ),

                Divider(),

                /// price distance
                ListTile(
                  leading: Icon(Icons.currency_rupee_outlined),
                  title: PriceText01(price: order.price),
                ),

                context.gapMD,

                /// Cancel
                ElevatedButton(
                  onPressed: CurrOrderService01().cancelCurrOrder,
                  child: const Text('Cancel Order'),
                ),
                context.gapLG,
              ],
            ),
          ),
        );
      },
    );
  }
}
