import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:scrapper/Services/GeoLocatorService/GeoLocator01.dart';
import 'package:scrapper/Services/NominatimServices/NominatimServices01.dart';

class CurrAddTest01 extends StatelessWidget {
  const CurrAddTest01({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: GeoLocator01(),
    builder: (context, position, _) => FutureBuilder(
      future: NominatimServices01().searchByLatLng(
        LatLng(position?.latitude ?? 0, position?.longitude ?? 0),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('Loading...');
        }

        if (!snapshot.hasData || snapshot.data?.name == null) {
          return const Text('No address');
        }

        final name = snapshot.data!.name!;
        final data = name.length > 10 ? name.substring(0, 10) : name;
        return Text('$data...', overflow: TextOverflow.ellipsis, maxLines: 1);
      },
    ),
  );
}
