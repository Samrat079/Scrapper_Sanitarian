import 'package:flutter/cupertino.dart';

import '../../../theme/theme_extensions.dart';

class RichText01 extends StatelessWidget {
  final String text1, text2, text3;
  final double fontSize;
  final Color highlight;

  const RichText01({
    super.key,
    required this.text1,
    required this.text2,
    required this.text3,
    this.fontSize = 30,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: text1,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
              color: context.colorScheme.onSurface,
            ),
          ),
          TextSpan(
            text: text2,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
              color: highlight,
            ),
          ),
          TextSpan(
            text: text3,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
              color: context.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
