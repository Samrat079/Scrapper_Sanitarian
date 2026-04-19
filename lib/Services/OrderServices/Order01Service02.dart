import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../../Models/Orders/Order01.dart';
import '../GeoLocatorService/GeoLocator01.dart';
import '../OSRMServices/OSRMService01.dart';

class Order01Service02 extends ValueNotifier<List<Order01>> {
  static final Order01Service02 _instance = Order01Service02._internal();

  Order01Service02._internal() : super([]);

  factory Order01Service02() => _instance;

  StreamSubscription<QuerySnapshot<Order01>>? _orderSub;

  CollectionReference<Order01> get _ref => FirebaseFirestore.instance
      .collection('order01')
      .withConverter<Order01>(
        fromFirestore: Order01.fromFirestore,
        toFirestore: (model, _) => model.toJson(),
      );

  /// init
  void init() {
    if (_orderSub != null) return;

    _orderSub = _ref
        .where('status', whereIn: [Order01Status.requested.name])
        .snapshots()
        .listen((snapshot) async {
          final orders = snapshot.docs.map((doc) => doc.data()).toList();
          value = orders;
          await _attachDistances2(orders);
          value = List.from(orders);
        });
  }

  /// Calculates the distance from curr to destination
  Future<void> _attachDistances2(List<Order01> orders) {
    final current = GeoLocator01().getCurrLatLng();

    final destinations = orders.map((o) => o.address.latLng).toList();

    return OSRMService01()
        .distanceFromTable(current, destinations)
        .then(
          (distances) => orders.asMap().forEach((i, order) {
            order.distance = distances[i];
          }),
        )
        .catchError((_) => orders.forEach((order) => order.distance = null));
  }

  /// stop listener
  void stop() {
    _orderSub?.cancel();
    _orderSub = null;
    value = [];
  }

  /// Reject by id
  void rejectById(int index) {
    final newList = List<Order01>.from(value);
    newList.removeAt(index);
    value = newList;
  }

  void deleteById(String uid) => _ref.doc(uid).delete();
}
