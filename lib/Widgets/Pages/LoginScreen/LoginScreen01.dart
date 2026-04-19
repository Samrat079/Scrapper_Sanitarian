import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'AddNumber01.dart';
import 'AddOtp01.dart';

class LoginScreen01 extends StatelessWidget {
  const LoginScreen01({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = PageController(initialPage: 0);
    return Scaffold(
      body: PageView(
        controller: controller,
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        children: [
          AddNumber01(controller: controller),
          AddOtp01(controller: controller),
        ],
      ),
    );
  }
}
