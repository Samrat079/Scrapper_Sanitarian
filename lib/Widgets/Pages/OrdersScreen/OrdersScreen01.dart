import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrapper/Models/Orders/Order01.dart';
import 'package:scrapper/Services/OrderServices/Order01Service02.dart';
import 'package:scrapper/Widgets/Custome/CenterColumn/CenterColumn04.dart';
import 'package:scrapper/Widgets/Pages/OrdersScreen/Widget/OrderCard01.dart';
import 'package:scrapper/theme/theme_extensions.dart';

import '../../../Services/AppUserServices/AppUserService03.dart';
import '../../../Services/OrderServices/OrderListService03.dart';

class OrdersScreen01 extends StatelessWidget {
  const OrdersScreen01({super.key});

  @override
  Widget build(BuildContext context) {
    final orderService = Order01Service02();
    void onAccept(String uid) =>
        orderService.acceptById(uid).then((_) => Navigator.pop(context));

    void onReject(int index) => orderService.rejectById(index);
    void onDelete(String uid) => orderService.deleteById(uid);

    return Scaffold(
      appBar: AppBar(),

      // body: ValueListenableBuilder<List<Order01>>(
      //   valueListenable: orderService,
      //   builder: (context, orders, _) {
      //     /// This is the empty state
      //     if (orders.isEmpty) {
      //       return CenterColumn04(
      //         centerVertically: true,
      //         children: [
      //           Image.asset('assets/Illustrations/search_01.png', width: 180),
      //           context.gapMD,
      //           LinearProgressIndicator(),
      //           context.gapMD,
      //           Text("Searching for orders", textAlign: TextAlign.center),
      //         ],
      //       );
      //     }
      //
      //     /// This is the order list
      //     return ListView.builder(
      //       itemCount: orders.length,
      //       itemBuilder: (context, index) {
      //         final data = orders[index];
      //         return OrderCard01(
      //           data: data,
      //           onDelete: () => onDelete(data.uid!),
      //           onReject: () => onReject(index),
      //           onAccept: () => onAccept(data.uid!),
      //         );
      //       },
      //     );
      //   },
      // ),
      body: Consumer<OrderListService03>(
        builder: (context, orderService, _) {
          final appUser = context.read<AppUserService03>();
          final orders = orderService.orders;

          /// 🟡 Empty state
          if (orders.isEmpty) {
            return CenterColumn04(
              centerVertically: true,
              children: [
                Image.asset('assets/Illustrations/search_01.png', width: 180),
                context.gapMD,
                const LinearProgressIndicator(),
                context.gapMD,
                const Text("Searching for orders", textAlign: TextAlign.center),
              ],
            );
          }

          /// 🟢 Order list
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final data = orders[index];

              return OrderCard01(
                data: data,

                /// 🔥 UI → calls service (no logic here)
                onDelete: () => orderService.deleteById(data.uid),
                onReject: () => orderService.rejectById(data.uid),
                onAccept: () {
                  orderService.accept(
                    data.uid!,
                    appUser.current.sanitarian?.toJson(),
                  );
                  Navigator.pop(context);
                },
              );
            },
          );
        },
      ),
    );
  }
}
