import 'package:flutter/material.dart';

class CardList01 extends StatelessWidget {
  /// Widgets
  final List<Widget> children;

  /// Layout
  final EdgeInsetsGeometry padding;

  /// Behaviour
  final ScrollPhysics physics;

  const CardList01({
    super.key,
    this.children = const [],
    this.padding = const EdgeInsetsGeometry.all(16),
    this.physics = const NeverScrollableScrollPhysics(),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Card(
          child: ListView(
            physics: physics,
            padding: padding,
            shrinkWrap: true,
            children: children,
          ),
        ),
      ),
    );
  }
}
