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

  /// Subscriptions
  /// For the order
  StreamSubscription<QuerySnapshot<Order01>>? _currOrderSub;

  /// For the current order
  CollectionReference<Order01> get _ref => FirebaseFirestore.instance
      .collection('order01')
      .withConverter(
        fromFirestore: Order01.fromFirestore,
        toFirestore: (model, _) => model.toJson(),
      );

  /// Timer for debouncing firestore update
  Timer? _firestoreTimer;

  /// Geolocator
  final geo = GeoLocator02();

  /// orderid
  String? _orderId;

  void init() {
    _currOrderSub?.cancel();

    final uid = AppUserService02().current.uid;
    _currOrderSub = _ref
        .where('sanitarian.uid', isEqualTo: uid)
        .where('status', isEqualTo: Order01Status.assigned.name)
        .limit(1)
        .snapshots()
        .listen((snapshot) async {
          if (snapshot.docs.isEmpty) return;

          final doc = snapshot.docs.first;

          _orderId = doc.id;
          value = doc.data();

          await _attachDistance(value!);
        });

    geo.addListener(_onLocationUpdate);
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
    final current = geo.getCurrLatLng();
    if (current == null) return;

    final shouldRefetch = _shouldRefetch(order, current);

    if (!shouldRefetch) return;

    await OSRMService01()
        .getRouteGeoJson(current, order.address.latLng)
        .then((data) => order.routesRes = data);

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

    /// If close to route → reuse
    if (minDistance < 50) {
      order.routesRes.coordinates = coords.sublist(closestIndex);
      order.routesRes.distance = Path.from(
        order.routesRes.coordinates,
      ).distance;
      return false;
    }

    /// Too far → refetch
    debugPrint("$minDistance m Refetching");
    return true;
  }

  void _updateFirestoreLocation(LatLng current) {
    _firestoreTimer?.cancel();

    _firestoreTimer = Timer(const Duration(seconds: 30), () {
      debugPrint("Updating firestore");
      _ref.doc(_orderId).update({
        'sanitarian.currLocation': GeoPoint(
          current.latitude,
          current.longitude,
        ),
      });
    });
  }

  bool verifyOtp(int otp) => value?.otp == otp;

  Future<void> cancelCurrOrder() async {
    value = null;
    await _ref.doc(_orderId).update({
      'status': Order01Status.requested.name,
      'sanitarian': null,
    });
  }

  Future<void> completeOrder() async {
    await _ref.doc(_orderId).update({'status': Order01Status.completed.name});
  }

  void stop() {
    // _currOrderSub?.cancel();
    _currOrderSub = null;
    geo.removeListener(_onLocationUpdate);
    value = null;
  }
}
