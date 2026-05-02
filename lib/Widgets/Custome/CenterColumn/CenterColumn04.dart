import 'package:flutter/cupertino.dart';

class CenterColumn04 extends StatelessWidget {
  final List<Widget> children;

  /// Layout
  final EdgeInsetsGeometry padding;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  /// Behavior
  final bool centerVertically;
  final bool centerHorizontally;

  final ScrollPhysics? physics;
  final ScrollController? scrollController;

  const CenterColumn04({
    super.key,
    this.children = const [],

    /// Default padding = 16
    this.padding = const EdgeInsets.all(16),

    this.mainAxisAlignment = MainAxisAlignment.start,

    /// Default stretch unless overridden
    this.crossAxisAlignment = CrossAxisAlignment.stretch,

    this.centerVertically = false,
    this.centerHorizontally = false,

    this.physics,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final column = Padding(
      padding: padding,
      child: Column(
        mainAxisAlignment: centerVertically
            ? MainAxisAlignment.center
            : mainAxisAlignment,
        crossAxisAlignment: centerHorizontally
            ? CrossAxisAlignment.center
            : crossAxisAlignment,
        children: children,
      ),
    );

    if (!centerVertically) {
      return SingleChildScrollView(
        controller: scrollController,
        physics: physics,
        child: column,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          controller: scrollController,
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
