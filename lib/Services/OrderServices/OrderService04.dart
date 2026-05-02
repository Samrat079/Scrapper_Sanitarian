import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:latlong2/latlong.dart';
import 'package:scrapper/Models/Orders/Order01.dart';
import 'package:scrapper/Services/GeoLocatorService/GeoLocator02.dart';

import '../OSRMServices/OSRMService01.dart';

class OrderService04 extends ValueNotifier<Order01?> {
  /// Singleton
  OrderService04._internal() : super(null);
  static final OrderService04 _instance = OrderService04._internal();

  factory OrderService04() => _instance;

  /// Sub will be used for the listener
  late final StreamSubscription? _sub;
  late final DocumentReference<Order01>? _docRef;

  /// Timer for debouncing firestore update
  Timer? _firestoreTimer;

  /// initialize the class with the order id
  void init(String orderId) {
    if (value?.uid == orderId) return;
    stop();
    _docRef = FirebaseFirestore.instance
        .collection('order01')
        .doc(orderId)
        .withConverter(
          fromFirestore: Order01.fromFirestore,
          toFirestore: (model, _) => model.toJson(),
        );
    _sub = _docRef?.snapshots().listen(_onDocUpdate);
    GeoLocator02().addListener(_onLocationUpdate);
  }

  void _onLocationUpdate() {
    final curr = value;
    if (curr == null) return;
    _processOrder(curr);
  }

  Future<void> _onDocUpdate(DocumentSnapshot<Order01> doc) async {
    if (!doc.exists) {
      value = null;
      notifyListeners();
      return;
    }
    await _processOrder(doc.data()!);
  }

  Future<void> _attachDistance(Order01 order) async {
    final current = GeoLocator02().getCurrLatLng();
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

  Future<void> _processOrder(Order01 order) async {
    await _attachDistance(order);
    value = order;
    notifyListeners();
  }

  void _updateFirestoreLocation(LatLng current) {
    _firestoreTimer?.cancel();

    _firestoreTimer = Timer(const Duration(seconds: 30), () {
      debugPrint("Updating firestore");
      _docRef?.update({
        'sanitarian.currLocation': GeoPoint(
          current.latitude,
          current.longitude,
        ),
      });
    });
  }

  Future<void> cancelCurrOrder() async {
    await _docRef?.update({
      'status': Order01Status.requested.name,
      'sanitarian': null,
    });
  }

  Future<void> completeOrder() async {
    await _docRef?.update({'status': Order01Status.completed.name});
  }

  void stop() {
    GeoLocator02().removeListener(_onLocationUpdate);
    _sub?.cancel();
    _sub = null;
    _docRef = null;
    value = null;
  }
}
