import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:scrapper/Models/Orders/Order01.dart';

class Order01Service02 extends ValueNotifier<List<Order01>> {
  /// Singleton
  Order01Service02() : super([]);

  StreamSubscription<QuerySnapshot<Order01>>? _orderSub;

  CollectionReference<Order01> get _ref => FirebaseFirestore.instance
      .collection('order01')
      .withConverter<Order01>(
        fromFirestore: Order01.fromFirestore,
        toFirestore: (model, _) => model.toJson(),
      );

  /// init
  void init() {
    _orderSub?.cancel();

    _orderSub = _ref
        .where('status', whereIn: [Order01Status.requested.name])
        .snapshots()
        .listen((snapshot) {
          if (snapshot.docs.isEmpty) {
            value = [];
          } else {
            value = snapshot.docs.map((doc) => doc.data()).toList();
          }
        });
  }

  /// dispose
  @override
  void dispose() {
    _orderSub?.cancel();
    super.dispose();
  }

  void rejectById(int index) {
    value.removeAt(index);
    notifyListeners();
  }
}
