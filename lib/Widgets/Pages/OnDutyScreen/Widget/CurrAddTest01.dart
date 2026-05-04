import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:scrapper/Services/NominatimServices/NominatimServices01.dart';

import '../../../../Services/GeoLocatorService/GeoLocator03.dart';
import '../../../../theme/theme_extensions.dart';

class CurrAddTest01 extends StatelessWidget {
  const CurrAddTest01({super.key});

  @override
  Widget build(BuildContext context) {
    Future<String>? addressFuture;
    LatLng lastLatLng = LatLng(0, 0);
    final Distance distance = const Distance();
    final nominatim = context.read<NominatimServices01>();

    void updateAddress(GeoLocator03 geo) {
      final pos = geo.currentLatLng;
      if (pos == null) {
        addressFuture = null;
        return;
      }

      /// Debouncing
      final double meters = distance(lastLatLng, pos);
      if (meters < 500) return;

      lastLatLng = pos;

      addressFuture = nominatim
          .searchByLatLng(pos)
          .then((res) {
            if (res.name == null || res.name!.trim().isEmpty) {
              return "${pos.latitude.toStringAsFixed(2)}, ${pos.longitude.toStringAsFixed(2)}";
            }
            return res.name!;
          })
          .catchError((_) {
            return "${pos.latitude.toStringAsFixed(2)}, ${pos.longitude.toStringAsFixed(2)}";
          });
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.3,
      child: Consumer<GeoLocator03>(
        builder: (context, geo, _) {
          final position = geo.currentLatLng;

          /// ❌ No location
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

          /// 🔄 Update future only when position changes
          updateAddress(geo);

          return FutureBuilder<String>(
            future: addressFuture,
            builder: (context, snapshot) {
              /// ⏳ Loading
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

              /// ❌ Error fallback
              if (snapshot.hasError || !snapshot.hasData) {
                final lat = position.latitude;
                final lng = position.longitude;

                return Row(
                  children: [
                    const Icon(Icons.error_outline, size: 16),
                    context.gapSM,
                    Expanded(
                      child: Text(
                        "${lat.toStringAsFixed(2)}, ${lng.toStringAsFixed(2)}",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                );
              }

              /// ✅ Success
              return Row(
                children: [
                  const Icon(Icons.location_on, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      snapshot.data!,
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
}
