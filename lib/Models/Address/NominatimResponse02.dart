import 'package:nominatim_flutter/model/response/nominatim_response.dart';

/// This is a extention for the Nominatimresponse
/// type which dosent has a toJson method adding it
/// also dosnet works

extension NominatimResponse02 on NominatimResponse {
  Map<String, dynamic> toJson() {
    return {
      'place_id': placeId,
      'licence': licence,
      'osm_type': osmType,
      'osm_id': osmId,
      'lat': lat,
      'lon': lon,
      'class': addressClass,
      'category': category,
      'type': type,
      'place_rank': placeRank,
      'importance': importance,
      'addresstype': addresstype,
      'name': name,
      'display_name': displayName,
      'address': address,
      'extratags': extraTags,
      'namedetails': nameDetails,
      'boundingbox': boundingbox,
    };
  }
}
