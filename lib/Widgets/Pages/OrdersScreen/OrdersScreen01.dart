import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:scrapper/Models/Orders/Order01.dart';
import 'package:scrapper/Services/GeoLocatorService/GeoLocator01.dart';
import 'package:scrapper/Services/OrderServices/Order01Service02.dart';
import 'package:scrapper/Widgets/Custome/CardList01/CardList01.dart';
import 'package:scrapper/Widgets/Custome/CenterColumn/CenterColumn04.dart';
import 'package:scrapper/Widgets/Custome/Intl/KmText01.dart';
import 'package:scrapper/Widgets/Custome/Intl/PriceText01.dart';
import 'package:scrapper/theme/theme_extensions.dart';
import 'package:timeago/timeago.dart' as timeago;

class OrdersScreen01 extends StatelessWidget {
  const OrdersScreen01({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: ValueListenableBuilder<List<Order01>>(
      valueListenable: Order01Service02(),
      builder: (context, orders, _) {
        if (orders.isEmpty) {
          return CenterColumn04(
            centerVertically: true,
            children: [
              LinearProgressIndicator(),
              context.gapMD,
              Text("Searching for orders", textAlign: TextAlign.center),
            ],
          );
        }

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final data = orders[index];
            return CardList01(
              padding: context.paddingMD,
              children: [
                PriceText01(price: data.price),
                SizedBox(
                  height: 32,
                  child: Row(
                    children: [
                      Text(
                        '${(data.routesRes.distance / 1000).toStringAsFixed(2)}Km',
                      ),
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
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Order01Service02().rejectById(index),
                      icon: Icon(Icons.cancel_outlined),
                    ),
                    IconButton(
                      onPressed: () => Order01Service02()
                          .acceptById(data.uid!)
                          .then((_) => Navigator.pop(context)),
                      icon: Icon(Icons.check_circle_outline),
                    ),
                    // IconButton(
                    //   onPressed: () => Order01Service02().deleteById(data.uid!),
                    //   icon: Icon(Icons.delete_outline),
                    // ),
                  ],
                ),
              ],
            );
          },
        );
      },
    ),
  );
}
