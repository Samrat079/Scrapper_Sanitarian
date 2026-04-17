import 'package:flutter/material.dart';

import '../../Custome/CenterColumn/CenterColumn04.dart';

class ErrorScreen01 extends StatelessWidget {
  const ErrorScreen01({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: CenterColumn04(
        centerVertically: true,
        children: [Text('Something went wrong')],
      ),
    );
  }
}
