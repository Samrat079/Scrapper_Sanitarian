import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:scrapper/Services/GeoLocatorService/GeoLocator02.dart';
import 'package:scrapper/Services/NominatimServices/NominatimServices01.dart';

import '../../../../theme/theme_extensions.dart';

class CurrAddTest01 extends StatelessWidget {
  const CurrAddTest01({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: MediaQuery.of(context).size.width * 0.3,
    child: ValueListenableBuilder(
      valueListenable: GeoLocator02(),
      builder: (context, position, _) {
        // 🚫 Location not available
        if (position == null) {
          return Row(
            children: [
              const Icon(Icons.location_off, size: 16),
              context.gapSM,
              const Expanded(
                child: Text(
                  "Location unavailable",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          );
        }

        return FutureBuilder(
          future: NominatimServices01().searchByLatLng(
            LatLng(position.latitude ?? 0, position.longitude ?? 0),
          ),
          builder: (context, snapshot) {
            final lat = position.latitude;
            final lng = position.longitude;

            // ⏳ Loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Row(
                children: [
                  const Icon(Icons.location_on, size: 16),
                  context.gapSM,
                  const SizedBox(
                    height: 10,
                    width: 10,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  context.gapSM,
                  const Expanded(
                    child: Text(
                      "Locating...",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              );
            }

            // ❌ API error
            if (snapshot.hasError) {
              return Row(
                children: [
                  const Icon(Icons.error_outline, size: 16),
                  context.gapSM,
                  const Expanded(
                    child: Text(
                      "Failed to fetch address",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              );
            }

            String text;

            // ⚠️ Empty / null name → fallback to lat/lng
            if (!snapshot.hasData ||
                snapshot.data?.name == null ||
                snapshot.data!.name!.trim().isEmpty) {
              text = "${lat?.toStringAsFixed(2)}, ${lng?.toStringAsFixed(2)}";
            } else {
              text = snapshot.data!.name!;
            }

            return Row(
              children: [
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    text,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
              ],
            );
          },
        );
      },
    ),
  );
}
