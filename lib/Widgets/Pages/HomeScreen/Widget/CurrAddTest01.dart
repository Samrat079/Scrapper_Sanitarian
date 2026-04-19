import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nominatim_flutter/model/response/nominatim_response.dart';
import 'package:scrapper/Services/GeoLocatorService/GeoLocator01.dart';
import 'package:scrapper/Services/NominatimServices/NominatimServices01.dart';

class CurrAddTest01 extends StatelessWidget {
  const CurrAddTest01({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<NominatimResponse?>(
      future: GeoLocator01().getCurrAddress(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('error:${snapshot.error}'));
        }
        final data = snapshot.data!.name;
        return Text('Curr Address: ${data}');
      },
    );
  }
}
