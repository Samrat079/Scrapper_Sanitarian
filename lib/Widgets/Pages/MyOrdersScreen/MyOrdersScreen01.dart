import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrapper/Widgets/Custome/OrderCard/OrderCard02.dart';

import '../../../Services/OrderServices/OrderListService04.dart';

class MyOrdersScreen01 extends StatelessWidget {
  const MyOrdersScreen01({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Consumer<OrderListService04>(
        builder: (context, service, _) {
          final orders = service.orders;
          if (orders.isEmpty) {
            return const Text("No orders");
          }
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (_, index) => OrderCard02(order: orders[index], onTap: () {},),
          );
        },
      ),
    );
  }
}
