import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:scrapper/Services/AppUserServices/AppUserService02.dart';
import 'package:scrapper/Services/GeoLocatorService/GeoLocator02.dart';
import 'package:scrapper/Services/OrderServices/OrderService03.dart';

import '../../Models/Orders/Order01.dart';
import '../GeoLocatorService/GeoLocator03.dart';
import '../OSRMServices/OSRMService01.dart';
import 'OrderService04.dart';

class OrderListService03 extends ChangeNotifier {
  OrderListService03(this.geo, this.orderService);

  late GeoLocator03 geo;
  late OrderService04 orderService;

  StreamSubscription<QuerySnapshot<Order01>>? _sub;

  List<Order01> _orders = [];

  List<Order01> get orders => _orders;

  CollectionReference<Order01> get _ref => FirebaseFirestore.instance
      .collection('order01')
      .withConverter<Order01>(
        fromFirestore: Order01.fromFirestore,
        toFirestore: (model, _) => model.toJson(),
      );

  void updateDependencies(GeoLocator03 newGeo, OrderService04 newOrderService) {
    geo.removeListener(_onLocationUpdate);
    geo = newGeo;
    orderService = newOrderService;
    if (_sub != null) geo.addListener(_onLocationUpdate);
  }

  void init() {
    if (_sub != null) return;

    _sub = _ref
        .where('status', whereIn: [Order01Status.requested.name])
        .snapshots()
        .listen((snapshot) async {
          _orders = snapshot.docs.map((e) => e.data()).toList();

          await _attachDistances();
          notifyListeners();
        });

    geo.addListener(_onLocationUpdate);
  }

  void _onLocationUpdate() {
    if (_orders.isEmpty) return;

    _attachDistances().then((_) => notifyListeners());
  }

  Future<void> _attachDistances() async {
    final current = geo.currentLatLng;
    if (current == null) return;

    final destinations = _orders.map((o) => o.address.latLng).toList();

    final data = await OSRMService01().distanceFromTable(current, destinations);

    for (int i = 0; i < _orders.length; i++) {
      _orders[i].routesRes = data[i];
    }
  }

  Future<void> checkActiveOrder(String sanitarianUid) async {
    final doc = await _ref
        .where('sanitarian.uid', isEqualTo: sanitarianUid)
        .where('status', whereIn: [Order01Status.assigned.name])
        .limit(1)
        .get();

    if (doc.docs.isNotEmpty) {
      final order = doc.docs.first.data();
      if (order.uid == null) return;
      orderService.init(order.uid!);
    }
  }

  void rejectById(String? uid) {
    if (uid == null) return;
    _orders = _orders.where((o) => o.uid != uid).toList();
    notifyListeners();
  }

  void deleteById(String? uid) async {
    if (uid == null) return;
    await _ref.doc(uid).delete();
    notifyListeners();
  }

  Future<void> accept(String uid, Map<String, dynamic>? sanitarian) async {
    orderService.init(uid);

    await _ref.doc(uid).update({
      'status': Order01Status.assigned.name,
      'sanitarian': sanitarian,
    });
  }

  void stop() {
    _sub?.cancel();
    geo.removeListener(_onLocationUpdate);

    _sub = null;
    _orders = [];

    notifyListeners();
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
