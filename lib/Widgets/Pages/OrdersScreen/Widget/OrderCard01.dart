import 'package:duration/duration.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../Models/Orders/Order01.dart';
import '../../../../theme/theme_extensions.dart';
import '../../../Custome/CardList01/CardList01.dart';
import '../../../Custome/Intl/PriceText01.dart';

class OrderCard01 extends StatelessWidget {
  final Order01 data;
  final VoidCallback onReject, onDelete, onAccept;

  const OrderCard01({
    super.key,
    required this.data,
    required this.onAccept,
    required this.onReject,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) => CardList01(
    padding: context.paddingMD,
    children: [
      PriceText01(price: data.price),
      SizedBox(
        height: 32,
        child: Row(
          children: [
            Text('${(data.routesRes.distance / 1000).toStringAsFixed(2)}Km'),
            VerticalDivider(),
            Text(
              data.routesRes.duration.pretty(
                abbreviated: true,
                tersity: DurationTersity.minute,
              ),
            ),
          ],
        ),
      ),
      Text(data.address.place.name.toString()),
      Text(data.address.place.displayName.toString()),
      Text(data.address.houseNo),
      context.gapMD,
      Row(
        children: [
          IconButton(
            onPressed: onReject,
            icon: Icon(Icons.cancel_outlined, size: 32),
            color: Colors.red,
          ),
          // context.gapMD,
          // IconButton(onPressed: onDelete, icon: Icon(Icons.delete_outline)),
          context.gapMD,
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onAccept,
              icon: Icon(Icons.check_circle_outline),
              label: Text('Accept'),
            ),
          ),
        ],
      ),
    ],
  );
}
