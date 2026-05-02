import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:scrapper/Models/Orders/Order01.dart';
import 'package:scrapper/Services/OrderServices/CurrOrderService02.dart';

import '../../../../../Services/MapLauncher/MapLauncher.dart';
import '../../../../../theme/theme_extensions.dart';
import '../../../Custome/CenterColumn/CenterColumn04.dart';
import '../../../Custome/Intl/PriceText01.dart';

class OrderAcceptSheet01 extends StatelessWidget {
  final Order01 order;
  final ScrollController controller;
  final VoidCallback onCancel, onComplete;

  const OrderAcceptSheet01({
    super.key,
    required this.order,
    required this.controller,
    required this.onCancel,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CenterColumn04(
        padding: context.paddingMD,
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

          ///  complete order
          ElevatedButton.icon(
            onPressed: onComplete,
            label: Text("Complete order"),
            icon: Icon(Icons.check),
          ),
          context.gapMD,

          /// Cancel
          ElevatedButton.icon(
            onPressed: onCancel,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colorScheme.errorContainer,
              foregroundColor: context.colorScheme.onErrorContainer,
            ),
            label: const Text('Cancel Order'),
            icon: Icon(Icons.cancel_outlined),
          ),
        ],
      ),
    );
  }
}
