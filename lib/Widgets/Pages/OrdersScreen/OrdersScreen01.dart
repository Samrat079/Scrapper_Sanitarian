import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrapper/Widgets/Custome/CenterColumn/CenterColumn04.dart';
import 'package:scrapper/Widgets/Custome/OrderCard/OrderCard01.dart';
import 'package:scrapper/theme/theme_extensions.dart';

import '../../../Services/AppUserServices/AppUserService03.dart';
import '../../../Services/OrderServices/OrderListService03.dart';

class OrdersScreen01 extends StatelessWidget {
  const OrdersScreen01({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),

      body: Consumer<OrderListService03>(
        builder: (context, orderService, _) {
          final appUser = context.read<AppUserService03>();
          final orders = orderService.orders;

          /// empty state
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

          /// data state
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
