import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nominatim_flutter/model/response/nominatim_response.dart';

import 'NominatimResponse02.dart';

class Address02 {
  final String? id;
  final NominatimResponse place;
  final String houseNo, phoneNumber;

  Address02({
    this.id,
    required this.place,
    required this.houseNo,
    required this.phoneNumber,
  });

  factory Address02.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return Address02(
      id: snapshot.id,
      place: NominatimResponse.fromJson(data['place']),
      houseNo: data['houseNo'],
      phoneNumber: data['phoneNumber'],
    );
  }

  factory Address02.fromMap(Map<String, dynamic> json) => Address02(
    place: json['place'] as NominatimResponse,
    houseNo: json['houseNo'],
    phoneNumber: json['phoneNumber'],
  );

  Map<String, dynamic> toMap() => {
    'place': place.toJson(),
    'houseNo': houseNo,
    'phoneNumber': phoneNumber,
  };
}
