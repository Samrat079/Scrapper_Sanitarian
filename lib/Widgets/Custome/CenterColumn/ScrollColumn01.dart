import 'package:flutter/cupertino.dart';

class ScrollColumn01 extends StatelessWidget {
  final List<Widget> children;

  const ScrollColumn01({super.key, this.children = const []});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: children,
        ),
      ),
    );
  }
}
