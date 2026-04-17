import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:scrapper/theme/theme_extensions.dart';

class CenterColumb03 extends StatelessWidget {
  final List<Widget> children;
  const CenterColumb03({super.key,  this.children = const []});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}
