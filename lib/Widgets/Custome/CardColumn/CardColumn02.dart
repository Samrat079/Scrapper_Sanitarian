import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CardColumn02 extends StatelessWidget {
  final List<Widget> children;
  const CardColumn02({super.key, this.children = const []});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Card(
          margin: const EdgeInsets.all(0),
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}
