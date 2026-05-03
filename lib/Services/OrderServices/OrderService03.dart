import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:latlong2/latlong.dart';
import 'package:scrapper/Models/Orders/Order01.dart';
import 'package:scrapper/Services/AppUserServices/AppUserService02.dart';
import 'package:scrapper/Services/GeoLocatorService/GeoLocator02.dart';

import '../OSRMServices/OSRMService01.dart';

class OrderService03 extends ValueNotifier<Order01?> {
  static final OrderService03 _instance = OrderService03._internal();
  OrderService03._internal() : super(null);
  factory OrderService03() => _instance;

  /// Subscription
  StreamSubscription<DocumentSnapshot<Order01>>? _currOrderSub;

  /// Firestore ref
  CollectionReference<Order01> get _ref => FirebaseFirestore.instance
      .collection('order01')
      .withConverter(
        fromFirestore: Order01.fromFirestore,
        toFirestore: (model, _) => model.toJson(),
      );

  /// Timer
  Timer? _firestoreTimer;

  /// Geolocator
  final geo = GeoLocator02();

  /// ordered
  String? _orderId;

  /// ✅ REQUIRED orderId
  void init(String orderId) {
    _currOrderSub?.cancel();

    /// prevent duplicate listeners
    geo.removeListener(_onLocationUpdate);
    _orderId = orderId;
    _currOrderSub = _ref.doc(orderId).snapshots().listen((doc) async {
      if (_orderId == null) return;
      if (!doc.exists) return;
      value = doc.data();
      if (value != null) {
        await _attachDistance(value!);
      }
      notifyListeners();
    });

    geo.addListener(_onLocationUpdate);
  }

  void _onLocationUpdate() {
    if (_orderId == null) return;
    final curr = value;
    if (curr == null) return;

    _attachDistance(curr).then((_) {
      value = curr;
      notifyListeners();
    });
  }

  Future<void> _attachDistance(Order01 order) async {
    if (_orderId == null) return;
    final current = geo.getCurrLatLng();
    if (current == null) return;

    final shouldRefetch = _shouldRefetch(order, current);
    if (!shouldRefetch) return;

    final data = await OSRMService01().getRouteGeoJson(
      current,
      order.address.latLng,
    );

    order.routesRes = data;

    _updateFirestoreLocation(current);
  }

  bool _shouldRefetch(Order01 order, LatLng current) {
    final coords = order.routesRes.coordinates;
    if (coords.isEmpty) return true;

    double minDistance = double.infinity;
    int closestIndex = 0;

    for (int i = 0; i < coords.length; i++) {
      final d = Distance().as(LengthUnit.Meter, current, coords[i]);

      if (d < minDistance) {
        minDistance = d;
        closestIndex = i;
      }
    }

    if (minDistance < 50) {
      order.routesRes.coordinates = coords.sublist(closestIndex);
      order.routesRes.distance = Path.from(
        order.routesRes.coordinates,
      ).distance;
      return false;
    }

    debugPrint("$minDistance m Refetching");
    return true;
  }

  void _updateFirestoreLocation(LatLng current) {
    final id = _orderId;
    final curr = value;

    if (id == null || curr == null) return;

    /// ❗ Prevent update if order is no longer active
    if (curr.status != Order01Status.assigned) return;

    _firestoreTimer?.cancel();

    _firestoreTimer = Timer(const Duration(seconds: 30), () {
      debugPrint("Updating firestore");
      _ref.doc(id).update({
        'sanitarian.currLocation': GeoPoint(
          current.latitude,
          current.longitude,
        ),
      });
    });
  }

  Future<void> cancelCurrOrder() async {
    final id = _orderId;
    if (id == null) return;
    await _ref.doc(id).update({
      'status': Order01Status.requested.name,
      'sanitarian': null,
    });
  }

  Future<void> completeOrder() async {
    final id = _orderId;
    geo.removeListener(_onLocationUpdate);
    if (id == null) return;

    await _ref.doc(id).update({'status': Order01Status.completed.name});
  }

  void stop() {
    _currOrderSub?.cancel();
    _currOrderSub = null;

    _firestoreTimer?.cancel();

    geo.removeListener(_onLocationUpdate);

    _orderId = null;
    value = null;
  }
}
