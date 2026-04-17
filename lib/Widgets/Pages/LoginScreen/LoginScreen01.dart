import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'AddNumber01.dart';
import 'AddOtp01.dart';

class LoginScreen01 extends StatelessWidget {
  const LoginScreen01({super.key});

  @override
  Widget build(BuildContext context) {
    final _controller = PageController(initialPage: 0);
    return Scaffold(
      body: PageView(
        controller: _controller,
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        children: [
          AddNumber01(controller: _controller),
          AddOtp01(controller: _controller),
        ],
      ),
    );
  }
}
