import 'package:flutter/cupertino.dart';
import 'package:scrapper/Services/OrderServices/CurrOrderService01.dart';
import 'package:scrapper/Widgets/Pages/HomeScreen/OnDutyScreen/OnDutyScreen01.dart';

import 'CurrOrderScreen/CurrOrderScreen02.dart';

class HomeScreen01 extends StatelessWidget {
  const HomeScreen01({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: CurrOrderService01(),
      builder: (context, order, _) {
        if (order == null) return OnDutyScreen01();
        return CurrOrderScreen02();
      },
    );
  }
}
