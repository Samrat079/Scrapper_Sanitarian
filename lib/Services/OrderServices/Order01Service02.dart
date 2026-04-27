import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scrapper/Services/AppUserServices/AppUserService02.dart';

import '../../Models/Orders/Order01.dart';
import '../GeoLocatorService/GeoLocator01.dart';
import '../OSRMServices/OSRMService01.dart';

class Order01Service02 extends ValueNotifier<List<Order01>> {
  static final Order01Service02 _instance = Order01Service02._internal();

  Order01Service02._internal() : super([]);

  factory Order01Service02() => _instance;

  /// Subscriptions
  StreamSubscription<QuerySnapshot<Order01>>? _orderSub;
  StreamSubscription? _locSub;

  List<Order01> _cachedOrders = [];

  CollectionReference<Order01> get _ref => FirebaseFirestore.instance
      .collection('order01')
      .withConverter<Order01>(
        fromFirestore: Order01.fromFirestore,
        toFirestore: (model, _) => model.toJson(),
      );

  /// init
  void init() {
    if (_orderSub != null) return;

    /// Listen to orders
    _orderSub = _ref
        .where('status', whereIn: [Order01Status.requested.name])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) async {
          _cachedOrders = snapshot.docs.map((doc) => doc.data()).toList();
          await _attachDistances2(_cachedOrders);
          value = List.of(_cachedOrders);
        });

    /// Listen to location updates
    GeoLocator01().addListener(_onLocationUpdate);
  }

  void _onLocationUpdate() {
    if (_cachedOrders.isEmpty) return;

    _attachDistances2(_cachedOrders).then((_) {
      value = List.of(_cachedOrders);
    });
  }

  /// Calculates the distance from curr to destination
  Future<void> _attachDistances2(List<Order01> orders) async {
    final current = GeoLocator01().getCurrLatLng();
    if (current == null) return;

    final destinations = orders.map((o) => o.address.latLng).toList();

    final data = await OSRMService01().distanceFromTable(current, destinations);

    for (int i = 0; i < orders.length; i++) {
      orders[i].routesRes = data[i];
    }
  }

  /// stop listener
  void stop() {
    _orderSub?.cancel();
    GeoLocator01().removeListener(_onLocationUpdate);
    _orderSub = null;
    _locSub = null;
    value = [];
  }

  /// Reject by id
  void rejectById(int index) {
    final newList = List<Order01>.from(value);
    newList.removeAt(index);
    value = newList;
  }

  /// Accept by id
  Future<void> acceptById(String uid) => _ref.doc(uid).update({
    'status': Order01Status.assigned.name,
    'sanitarian': AppUserService02().current.sanitarian?.toJson(),
  });

  void deleteById(String uid) => _ref.doc(uid).delete();
}
