import 'package:flutter/material.dart';
import 'package:scrapper/Widgets/Custome/Forms/EditProfileForm01.dart';
import 'package:scrapper/Widgets/Pages/LoginScreen/Widget/EditProfileView01.dart';
import 'package:scrapper/Widgets/Pages/LoginScreen/Widget/Welcome01.dart';
import 'package:scrapper/Widgets/Pages/LoginScreen/Widget/Welcome02.dart';

import 'Widget/AddNumber01.dart';
import 'Widget/AddOtp01.dart';

class LoginScreen01 extends StatelessWidget {
  const LoginScreen01({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = PageController(initialPage: 0);
    return Scaffold(
      body: PageView(
        controller: controller,
        physics: NeverScrollableScrollPhysics(),
        children: [
          Welcome01(controller: controller),
          Welcome02(controller: controller),
          AddNumber01(controller: controller),
          AddOtp01(controller: controller),
          EditProfileView01(controller: controller)
        ],
      ),
    );
  }
}
