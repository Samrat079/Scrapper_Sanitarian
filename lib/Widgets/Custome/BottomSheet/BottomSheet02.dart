import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scrapper/Widgets/Custome/CenterColumn/CenterColumb02.dart';
import 'package:scrapper/Widgets/Custome/CenterColumn/CenterColumb03.dart';

class BottomSheet02 extends StatefulWidget {
  const BottomSheet02({super.key});

  @override
  State<BottomSheet02> createState() => _BottomSheet02State();
}

class _BottomSheet02State extends State<BottomSheet02> {
  @override
  Widget build(BuildContext context) {
    return CenterColumb03(
      children: [

        /// Details
        TextField(decoration: InputDecoration(labelText: 'Area/Locality')),
        TextField(
          decoration: InputDecoration(labelText: 'house no., Flat, Floor'),
        ),
        TextField(decoration: InputDecoration(labelText: 'Contact number')),


        /// Submit
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          child: Text('Search'),
        ),
      ],
    );
  }
}
