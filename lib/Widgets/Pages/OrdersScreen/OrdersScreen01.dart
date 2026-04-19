import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scrapper/Models/Orders/Order01.dart';
import 'package:scrapper/Services/OrderServices/Order01Service02.dart';
import 'package:scrapper/Widgets/Custome/CardList01/CardList01.dart';
import 'package:scrapper/Widgets/Custome/CenterColumn/CenterColumn04.dart';
import 'package:scrapper/Widgets/Custome/Intl/KmText01.dart';
import 'package:scrapper/Widgets/Custome/Intl/PriceText01.dart';
import 'package:scrapper/theme/theme_extensions.dart';

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
                KmText01(meters: data.distance!),
                Text(data.address.place.name.toString()),
                Text(data.address.place.displayName.toString()),
                Text(data.status.name),
                // Text(data.uid!),
                TextButton(
                  onPressed: () => Order01Service02().deleteById(data.uid!),
                  child: Text('delete'),
                ),
              ],
            );
          },
        );
      },
    ),
  );
}
