import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:scrapper/Services/NominatimServices/NominatimServices01.dart';

import '../../../../Services/GeoLocatorService/GeoLocator03.dart';
import '../../../../theme/theme_extensions.dart';

class CurrAddTest01 extends StatefulWidget {
  const CurrAddTest01({super.key});

  @override
  State<CurrAddTest01> createState() => _CurrAddTest01State();
}

class _CurrAddTest01State extends State<CurrAddTest01> {
  Future<String>? _addressFuture;
  LatLng? _lastLatLng;

  void _updateAddress(GeoLocator03 geo) {
    final pos = geo.currentLatLng;
    if (pos == null) {
      _addressFuture = null;
      return;
    }

    /// Debouncing
    if (_lastLatLng != null &&
        _lastLatLng!.latitude == pos.latitude &&
        _lastLatLng!.longitude == pos.longitude) {
      return;
    }

    _lastLatLng = pos;

    _addressFuture = NominatimServices01()
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

  @override
  Widget build(BuildContext context) {
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
          _updateAddress(geo);

          return FutureBuilder<String>(
            future: _addressFuture,
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
                final lat = position.latitude ?? 0;
                final lng = position.longitude ?? 0;

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
