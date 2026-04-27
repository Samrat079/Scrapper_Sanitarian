import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:scrapper/Models/Orders/Order01.dart';
import 'package:scrapper/Services/GeoLocatorService/GeoLocator01.dart';

import '../../../../../Services/MapLauncher/MapLauncher.dart';
import '../../../../../Services/OrderServices/CurrOrderService01.dart';
import '../../../../../theme/theme_extensions.dart';
import '../../../../Custome/CenterColumn/CenterColumn04.dart';
import '../../../../Custome/Intl/PriceText01.dart';

class OrderAcceptBottomSheet01 extends StatelessWidget {
  final Order01 order;
  final ScrollController controller;

  const OrderAcceptBottomSheet01({
    super.key,
    required this.order,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return CenterColumn04(
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
                  // subtitle: Text(
                  //   '${(GeoLocator01().calDistance(order.routesRes.coordinates) / 1000).toStringAsFixed(2)} Km',
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
          title: Text(order.address.place.name ?? ''),
          subtitle: Text(order.address.place.displayName ?? ''),
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
          leading: const CircleAvatar(child: Icon(Icons.person_2_outlined)),
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
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colorScheme.errorContainer,
            foregroundColor: context.colorScheme.onErrorContainer,
          ),
          child: const Text('Cancel Order'),
        ),
        context.gapLG,
      ],
    );
  }
}
