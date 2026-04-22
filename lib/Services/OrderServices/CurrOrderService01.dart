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

  int getClosestIndex(LatLng current, List<LatLng> routePoints) {
    double minDist = double.infinity;
    int closestIndex = 0;

    for (int i = 0; i < routePoints.length; i++) {
      final dist = Distance().as(LengthUnit.Meter, current, routePoints[i]);

      if (dist < minDist) {
        minDist = dist;
        closestIndex = i;
      }
    }

    return closestIndex;
  }


  /// This iterates through the routePoints and checks for
  /// the highest distance between the curr point and the
  /// points in the list, this is to check if the user
  /// if going off track or not
  double distanceFromRoute(LatLng current, List<LatLng> routePoints) {
    double minDist = double.infinity;

    for (final point in routePoints) {
      final dist = Distance().as(LengthUnit.Meter, current, point);

      if (dist < minDist) {
        minDist = dist;
      }
    }

    return minDist;
  }
}
