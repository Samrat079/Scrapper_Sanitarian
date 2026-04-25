import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:latlong2/latlong.dart';
import 'package:nominatim_flutter/model/response/nominatim_response.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scrapper/Models/Orders/Order01.dart';
import 'package:scrapper/Services/AppUserServices/AppUserService02.dart';

import '../GeoLocatorService/GeoLocator01.dart';
import '../OSRMServices/OSRMService01.dart';

class CurrOrderService01 extends ValueNotifier<Order01?> {
  static final CurrOrderService01 _instance = CurrOrderService01._internal();

  CurrOrderService01._internal() : super(null);

  factory CurrOrderService01() => _instance;

  /// Subscriptions
  /// For the order
  StreamSubscription<QuerySnapshot<Order01>>? _currOrderSub;

  /// For the curr location
  StreamSubscription? _locSub;

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

    _locSub = GeoLocator01().positionStream
        .throttleTime(const Duration(seconds: 5))
        .listen((_) => _onLocationUpdate());
  }

  void _onLocationUpdate() {
    final curr = value;
    if (curr == null) return;

    _attachDistance(curr).then((_) {
      value = curr;
      notifyListeners();
    });
  }

  Future<void> _attachDistance(Order01 order) async {
    final current = GeoLocator01().getCurrLatLng();
    if (current == null) return;

    final destination = order.address.latLng;
    final res = await OSRMService01().getRouteGeoJson(current, destination);

    order.routesRes = res;
    await _ref.doc(value?.uid).update({
      'sanitarian.currLocation': GeoPoint(current.latitude, current.longitude),
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

  void stop() {
    _currOrderSub?.cancel();
    _locSub?.cancel();

    _currOrderSub = null;
    _locSub = null;

    value = null;
  }
}
