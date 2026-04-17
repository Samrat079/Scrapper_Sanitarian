import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:scrapper/Models/Address/Address02.dart';
import 'package:scrapper/Models/Orders/Order01.dart';
import 'package:scrapper/Services/AppUserServices/AppUserServices01.dart';

class Order01Service extends ValueNotifier<Order01?> {
  /// Singleton
  Order01Service() : super(null);

  StreamSubscription<QuerySnapshot<Order01>>? _orderSub;

  CollectionReference<Order01> get _ref => FirebaseFirestore.instance
      .collection('order01')
      .withConverter<Order01>(
        fromFirestore: Order01.fromFirestore,
        toFirestore: (model, _) => model.toJson(),
      );

  /// init
  void init() {
    final uid = AppUserServices01().current.uid;
    if (uid == null) return;

    _orderSub?.cancel();

    _orderSub = _ref
        .where('customer.uid', isEqualTo: uid)
        .where(
          'status',
          whereIn: [Order01Status.requested.name, Order01Status.assigned.name],
        )
        .snapshots()
        .listen((snapshot) {
          if (snapshot.docs.isEmpty) {
            value = null;
          } else {
            value = snapshot.docs.first.data();
          }
        });
  }

  /// dispose
  @override
  void dispose() {
    _orderSub?.cancel();
    super.dispose();
  }

  Future<void> placeOrder(double price, Address02 address) async {
    final customer = AppUserServices01().current.customer01!;
    final doc = _ref.doc();

    final order = Order01(
      uid: doc.id,
      price: price,
      address: address,
      customer: customer,
      createdAt: Timestamp.now(),
    );

    await doc.set(order);
    value = order;
  }

  Future<void> cancelCurrOrder() async {
    final id = value?.uid;
    await _ref.doc(id).update({'status': Order01Status.cancelled.name});
    value = null;
  }

  Future<void> statusById(String id, Order01Status status) {
    return _ref.doc(id).update({'status': status.name});
  }

  /// Extra streams if needed
  Stream<QuerySnapshot<Order01>> getAllOrders() => _ref.snapshots();

  Stream<QuerySnapshot<Order01>> getAllByStatus(Order01Status status) =>
      _ref.where('status', isEqualTo: status.name).snapshots();
}
