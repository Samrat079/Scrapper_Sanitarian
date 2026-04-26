import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:scrapper/Models/Orders/Order01.dart';
import 'package:scrapper/Services/GeoLocatorService/GeoLocator01.dart';
import 'package:scrapper/Services/OrderServices/Order01Service02.dart';
import 'package:scrapper/Widgets/Custome/CardList01/CardList01.dart';
import 'package:scrapper/Widgets/Custome/CenterColumn/CenterColumn04.dart';
import 'package:scrapper/Widgets/Custome/Intl/KmText01.dart';
import 'package:scrapper/Widgets/Custome/Intl/PriceText01.dart';
import 'package:scrapper/Widgets/Pages/OrdersScreen/Widget/OrderCard01.dart';
import 'package:scrapper/theme/theme_extensions.dart';
import 'package:timeago/timeago.dart' as timeago;

class OrdersScreen01 extends StatelessWidget {
  const OrdersScreen01({super.key});

  @override
  Widget build(BuildContext context) {
    void onAccept(String uid) =>
        Order01Service02().acceptById(uid).then((_) => Navigator.pop(context));

    void onReject(int index) => Order01Service02().rejectById(index);
    void onDelete(String uid) => Order01Service02().deleteById(uid);

    return Scaffold(
      appBar: AppBar(),
      body: ValueListenableBuilder<List<Order01>>(
        valueListenable: Order01Service02(),
        builder: (context, orders, _) {
          /// This is the empty state
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

          /// This is the order list
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final data = orders[index];
              return OrderCard01(
                data: data,
                onDelete: () => onDelete(data.uid!),
                onReject: () => onReject(index),
                onAccept: () => onAccept(data.uid!),
              );
            },
          );
        },
      ),
    );
  }
}
