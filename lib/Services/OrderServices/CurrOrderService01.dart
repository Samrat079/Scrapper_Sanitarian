import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:latlong2/latlong.dart';
import 'package:nominatim_flutter/model/response/nominatim_response.dart';
import 'package:scrapper/Models/Orders/Order01.dart';
import 'package:scrapper/Services/AppUserServices/AppUserService02.dart';

class CurrOrderService01 extends ValueNotifier<Order01?> {
  static final CurrOrderService01 _instance = CurrOrderService01._internal();

  CurrOrderService01._internal() : super(null);

  factory CurrOrderService01() => _instance;

  StreamSubscription<QuerySnapshot<Order01>>? _currOrderSub;

  CollectionReference<Order01> get _ref => FirebaseFirestore.instance
      .collection('order01')
      .withConverter(
        fromFirestore: Order01.fromFirestore,
        toFirestore: (model, _) => model.toJson(),
      );

  void init() {
    _currOrderSub?.cancel();

    final uid = AppUserService02().current.uid;
    _currOrderSub = _ref
        .where('sanitarian.uid', isEqualTo: uid)
        .where('status', isEqualTo: Order01Status.assigned.name)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.docs.isEmpty) return value = null;
          value = snapshot.docs.first.data();
        });
  }

  Future<void> cancelCurrOrder() async {
    final id = value?.uid;
    value = null;
    await _ref.doc(id).update({
      'status': Order01Status.requested.name,
      'sanitarian': null,
    });
  }

  LatLng latLngFromPlace(NominatimResponse place) {
    if (place.lat == null || place.lon == null) return LatLng(0, 0);
    return LatLng(double.parse(place.lat!), double.parse(place.lon!));
  }
}
