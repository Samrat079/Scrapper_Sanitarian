import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:scrapper/Models/Orders/Order01.dart';
import 'package:scrapper/Services/OrderServices/Order01Service.dart';
import 'package:scrapper/theme/theme_extensions.dart';

import '../../Custome/CenterColumn/CenterColumn04.dart';

class CurrOrderScreen01 extends StatelessWidget {
  const CurrOrderScreen01({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Order01?>(
      valueListenable: Order01Service(),
      builder: (context, order, _) {
        if (order == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text('Thre is not data')),
          );
        }

        final coordinates = LatLng(
          double.parse(order.address.place.lat!),
          double.parse(order.address.place.lon!),
        );

        void cancelOrder() async {
          await Order01Service().cancelCurrOrder();
          Navigator.pop(context);
        }

        return Scaffold(
          appBar: AppBar(),
          body: FlutterMap(
            options: MapOptions(initialCenter: coordinates, initialZoom: 18),
            children: [
              TileLayer(
                urlTemplate:
                    "https://mt.google.com/vt/lyrs=m&x={x}&y={y}&z={z}",
                userAgentPackageName: "com.example.scrapper",
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: coordinates,
                    child: const Icon(
                      Icons.location_pin,
                      size: 40,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          bottomSheet: BottomSheet(
            onClosing: () {},
            builder: (context) {
              /// Temporary testing logic change this to == in prod
              if (order.sanitarian != null) {
                return CenterColumn04(
                  children: [
                    Center(child: CircularProgressIndicator()),
                    context.gapMD,
                    Text('Looking for sanitarians in your area'),
                  ],
                );
              }

              return CenterColumn04(
                children: [
                  Text(order.address.place.displayName!),
                  context.gapMD,
                  Text(order.address.houseNo),
                  context.gapMD,
                  ElevatedButton(onPressed: cancelOrder, child: Text('Cancel')),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
