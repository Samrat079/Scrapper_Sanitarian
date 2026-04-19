import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:scrapper/Services/GeoLocatorService/GeoLocator01.dart';
import 'package:scrapper/Widgets/Custome/Drawers/Drawer01.dart';
import 'package:scrapper/Widgets/Custome/RichText/RichText01.dart';
import 'package:scrapper/Widgets/Pages/HomeScreen/Widget/CurrAddTest01.dart';
import 'package:scrapper/theme/theme_extensions.dart';

import '../../Custome/CenterColumn/CenterColumn04.dart';

class HomeScreen01 extends StatelessWidget {
  const HomeScreen01({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: CenterColumn04(
        centerVertically: true,
        padding: context.paddingXL,
        children: [
          Image.asset('assets/Illustrations/home_01.png', height: 300),
          context.gapMD,

          CurrAddTest01(),

          context.gapMD,
          // RichText(
          //   textAlign: TextAlign.center,
          //   text: TextSpan(
          //     children: [
          //       TextSpan(
          //         text: 'Ready to make ',
          //         style: TextStyle(
          //           fontWeight: FontWeight.bold,
          //           fontSize: 30,
          //           color: context.colorScheme.onSurface,
          //         ),
          //       ),
          //       TextSpan(
          //         text: ' your city spotless? ',
          //         style: TextStyle(
          //           fontWeight: FontWeight.bold,
          //           fontSize: 30,
          //           color: context.colorScheme.primary,
          //         ),
          //       ),
          //       TextSpan(
          //         text: 'Go on duty now!!!',
          //         style: TextStyle(
          //           fontWeight: FontWeight.bold,
          //           fontSize: 30,
          //           color: context.colorScheme.onSurface,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),

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
