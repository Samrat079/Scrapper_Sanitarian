import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:scrapper/Services/GeoLocatorService/GeoLocator02.dart';
import 'package:scrapper/Services/NominatimServices/NominatimServices01.dart';
import 'package:scrapper/Services/OSRMServices/OSRMService01.dart';
import 'package:scrapper/Widgets/Custome/CardList01/CardList01.dart';

class LocationCard01 extends StatelessWidget {
  const LocationCard01({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: GeoLocator02(),
    builder: (context, position, _) {
      return CardList01(children: [Text(position.toString())]);
    },
  );
}
