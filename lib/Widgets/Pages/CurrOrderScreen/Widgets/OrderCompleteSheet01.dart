import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scrapper/Models/Orders/Order01.dart';
import 'package:scrapper/Widgets/Custome/CenterColumn/CenterColumn04.dart';
import 'package:scrapper/theme/theme_extensions.dart';

class OrderCompleteSheet01 extends StatelessWidget {
  final Order01 order;
  final ScrollController controller;
  final VoidCallback onComplete;

  const OrderCompleteSheet01({
    super.key,
    required this.onComplete,
    required this.order,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CenterColumn04(
        scrollController: controller,
        centerVertically: true,
        children: [
          Icon(Icons.done_all, size: context.textTheme.displayLarge?.fontSize),
          context.gapMD,
          Text(
            "Order completed",
            textAlign: TextAlign.center,
            style: context.textTheme.titleLarge,
          ),
          context.gapMD,
          Text(
            "Order status ${order.status.name}",
            textAlign: TextAlign.center,
            style: context.textTheme.titleLarge,
          ),
          context.gapMD,
          ElevatedButton.icon(
            onPressed: onComplete,
            label: Text("Done"),
            icon: Icon(Icons.check),
          ),
        ],
      ),
    );
  }
}
