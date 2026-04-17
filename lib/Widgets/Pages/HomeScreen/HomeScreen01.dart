import 'package:flutter/material.dart';
import 'package:scrapper/Models/Address/Address02.dart';
import 'package:scrapper/Widgets/Custome/Drawers/Drawer01.dart';
import 'package:scrapper/theme/theme_extensions.dart';

import '../../Custome/CenterColumn/CenterColumn01.dart';

class HomeScreen01 extends StatelessWidget {
  const HomeScreen01({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: CenterColumn01(
        children: [
          Image.asset('assets/Illustrations/home_01.png', height: 300),

          SizedBox(height: 16),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Too tired to',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                TextSpan(
                  text: ' take the trash out? ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                TextSpan(
                  text: 'We will do it for you!!!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              // backgroundColor: Theme.of(context).colorScheme.primary,
              // foregroundColor: Theme.of(context).colorScheme.onPrimary,
              backgroundColor: context.colorScheme.primary,
              foregroundColor: context.colorScheme.onPrimary
            ),
            onPressed: () => Navigator.pushNamed<Address02>(
              context,
              '/location01',
            ).then((result) => print(result)),
            child: Text('Book now'),
          ),
        ],
      ),
      drawer: Drawer01(),
    );
  }
}
