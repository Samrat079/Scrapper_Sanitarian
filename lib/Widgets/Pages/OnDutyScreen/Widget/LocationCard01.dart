import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:scrapper/Services/GeoLocatorService/GeoLocator01.dart';
import 'package:scrapper/Services/NominatimServices/NominatimServices01.dart';
import 'package:scrapper/Services/OSRMServices/OSRMService01.dart';
import 'package:scrapper/Widgets/Custome/CardList01/CardList01.dart';

class LocationCard01 extends StatelessWidget {
  const LocationCard01({super.key});

  @override
  Widget build(BuildContext context) => StreamBuilder(
    stream: GeoLocator01().locationLabelStream,
    builder: (context, snapshot) {
      if (snapshot.data == null) {
        return CardList01(children: [LinearProgressIndicator()]);
      }

      return CardList01(children: [Text(snapshot.data!)]);
    },
  );
}
