import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CardList01 extends StatelessWidget {
  final List<Widget> children;

  const CardList01({super.key, this.children = const []});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Card(
          child: ListView(
            padding: EdgeInsets.all(0),
            shrinkWrap: true,
            children: children,
          ),
        ),
      ),
    );
  }
}
