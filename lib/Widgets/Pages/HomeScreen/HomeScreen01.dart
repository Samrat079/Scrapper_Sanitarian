import 'package:flutter/cupertino.dart';
import 'package:scrapper/Services/OrderServices/CurrOrderService02.dart';

import '../CurrOrderScreen/CurrOrderScreen02.dart';
import '../OnDutyScreen/OnDutyScreen01.dart';

class HomeScreen01 extends StatelessWidget {
  const HomeScreen01({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: CurrOrderService02(),
      builder: (context, order, _) {
        if (order == null) return OnDutyScreen01();
        return CurrOrderScreen02();
      },
    );
  }
}
