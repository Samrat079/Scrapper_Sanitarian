import 'package:flutter/material.dart';
import 'package:scrapper/Services/OrderServices/CurrOrderService01.dart';
import 'package:scrapper/Widgets/Custome/Drawers/Drawer01.dart';
import 'package:scrapper/Widgets/Custome/RichText/RichText01.dart';
import 'package:scrapper/theme/theme_extensions.dart';

import '../../../Custome/CenterColumn/CenterColumn04.dart';
import 'Widget/CurrAddTest01.dart';

class OnDutyScreen01 extends StatelessWidget {
  const OnDutyScreen01({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actionsPadding: context.paddingMD,
        // actions: [CurrAddTest01()],
      ),
      body: CenterColumn04(
        centerVertically: true,
        padding: context.paddingXL,
        children: [
          Image.asset('assets/Illustrations/waste_03.png', height: 300),
          context.gapMD,

          RichText01(
            text1: 'Ready to make ',
            text2: ' your city spotless? ',
            text3: 'Go on duty now!!!',
            highlight: context.colorScheme.primary,
          ),

          context.gapMD,

          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/orders'),
            child: Text('Go on duty'),
          ),
        ],
      ),
      drawer: Drawer01(),
    );
  }
}
