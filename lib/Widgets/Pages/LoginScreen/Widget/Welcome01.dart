import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scrapper/Widgets/Custome/CenterColumn/CenterColumn04.dart';
import 'package:scrapper/Widgets/Custome/RichText/RichText01.dart';
import 'package:scrapper/theme/theme_extensions.dart';

class Welcome01 extends StatelessWidget {
  final PageController _controller;

  const Welcome01({super.key, required PageController controller})
    : _controller = controller;

  @override
  Widget build(BuildContext context) {
    return CenterColumn04(
      centerVertically: true,
      padding: context.paddingXL,
      children: [
        Image.asset('assets/Illustrations/waste_01.png', height: 256),
        context.gapMD,

        RichText01(
          text1: 'Be part of keeping',
          text2: ' your community clean ',
          text3: 'and safe',
          highlight: context.colorScheme.primary,
        ),

        context.gapLG,

        ElevatedButton(
          onPressed: () => _controller.nextPage(
            duration: Duration(milliseconds: 300),
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
        //     2,
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
}
