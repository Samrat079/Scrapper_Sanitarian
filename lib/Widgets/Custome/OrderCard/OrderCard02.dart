import 'package:cached_network_image/cached_network_image.dart';
import 'package:duration/duration.dart';
import 'package:flutter/material.dart';

import '../../../../Models/Orders/Order01.dart';
import '../../../../theme/theme_extensions.dart';
import '../CardList01/CardList01.dart';
import '../CenterColumn/CenterColumn04.dart';
import '../Intl/PriceText01.dart';
import 'package:timeago/timeago.dart' as timeago;

class OrderCard02 extends StatelessWidget {
  final Order01 order;
  final VoidCallback onTap;

  const OrderCard02({super.key, required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        titleAlignment: ListTileTitleAlignment.top,
        contentPadding: context.paddingMD,
        visualDensity: VisualDensity(horizontal: 0.2, vertical: 0.2),

        /// prile
        leading: CachedNetworkImage(
          imageUrl: order.customer.photoUrl,
          imageBuilder: (context, imageProvider) =>
              CircleAvatar(radius: 28, backgroundImage: imageProvider),
          placeholder: (context, url) =>
              const CircleAvatar(radius: 28, child: Icon(Icons.person)),
        ),

        /// 👤 Name + Status
        title: Row(
          children: [
            Text(order.customer.displayName, overflow: TextOverflow.ellipsis),
            Spacer(),
            Text(order.status.name, style: context.textTheme.bodySmall),
          ],
        ),

        ///
        subtitle: CenterColumn04(
          padding: EdgeInsets.zero,
          children: [
            context.gapSM,

            /// 💰 Price
            PriceText01(price: order.price),

            /// display name
            Text(
              order.address.place.displayName ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            /// 🕒 Created At
            Text(
              timeago.format(order.createdAt.toDate()),
              style: context.textTheme.bodySmall,
              textAlign: TextAlign.end,
            ),
          ],
        ),
      ),
    );
  }
}
