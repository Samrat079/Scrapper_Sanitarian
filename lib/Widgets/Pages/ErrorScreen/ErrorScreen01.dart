import 'package:flutter/material.dart';

import '../../Custome/CenterColumn/CenterColumn01.dart';

class ErrorScreen01 extends StatelessWidget {
  const ErrorScreen01({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: CenterColumn01(children: [Text('Something went wrong')]),
    );
  }
}
