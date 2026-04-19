import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../theme/theme_extensions.dart';
import '../../../Custome/CenterColumn/CenterColumn04.dart';
import '../../../Custome/RichText/RichText01.dart';

class Welcome02 extends StatelessWidget {
  final PageController _controller;
  const Welcome02({super.key, required PageController controller}) : _controller = controller;

  @override
  Widget build(BuildContext context) => CenterColumn04(
    centerVertically: true,
    padding: context.paddingXL,
    children: [
      Image.asset('assets/Illustrations/waste_02.png', height: 256),
      context.gapMD,

      RichText01(
        text1: 'Find nearby tasks',
        text2: ' and make a difference ',
        text3: 'every day',
        highlight: context.colorScheme.primary,
      ),

      context.gapLG,

      ElevatedButton(
        onPressed: () => _controller.nextPage(
          duration: Duration(seconds: 1),
          curve: Curves.easeInOut,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colorScheme.primary,
          foregroundColor: context.colorScheme.onPrimary,
        ),
        child: Text('Next'),
      ),
      context.gapMD,
      // ElevatedButton(
      //   onPressed: () => _controller.animateTo(
      //     3,
      //     duration: Duration(milliseconds: 500),
      //     curve: Curves.easeInOut,
      //   ),
      //   style: ElevatedButton.styleFrom(
      //     backgroundColor: context.colorScheme.surfaceContainer,
      //     foregroundColor: context.colorScheme.onSurface,
      //   ),
      //   child: Text('Skip'),
      // ),
    ],
  );
}
