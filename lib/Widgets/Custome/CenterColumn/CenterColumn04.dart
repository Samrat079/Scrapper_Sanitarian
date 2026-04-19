import 'package:flutter/cupertino.dart';


class CenterColumn04 extends StatelessWidget {
  final List<Widget> children;

  /// Layout
  final EdgeInsetsGeometry padding;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  /// Behavior
  final bool centerVertically;
  final ScrollPhysics? physics;

  const CenterColumn04({
    super.key,
    this.children = const [],

    /// Default padding = 16
    this.padding = const EdgeInsets.all(16),

    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,

    this.centerVertically = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final column = Padding(
      padding: padding,
      child: Column(
        mainAxisAlignment:
        centerVertically ? MainAxisAlignment.center : mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children,
      ),
    );

    if (!centerVertically) {
      return SingleChildScrollView(
        physics: physics,
        child: column,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: physics,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: column,
          ),
        );
      },
    );
  }
}
