import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:scrapper/Widgets/Pages/CurrOrderScreen/CurrOrderScreen03.dart';

import '../../../Services/OrderServices/OrderService04.dart';
import '../OnDutyScreen/OnDutyScreen01.dart';

class HomeScreen01 extends StatelessWidget {
  const HomeScreen01({super.key});

  @override
  Widget build(BuildContext context) {
    // return ValueListenableBuilder(
    //   valueListenable: OrderService03(),
    //   builder: (context, order, _) {
    return Consumer<OrderService04>(
      builder: (context, orderService, _) {
        final order = orderService.order;
        if (order == null) return OnDutyScreen01();
        // return CurrOrderScreen02(orderId: order.uid!);
        return CurrOrderScreen03();
      },
    );
  }
}
