import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:latlong2/latlong.dart';
import 'package:scrapper/Models/Orders/Order01.dart';
import 'package:scrapper/Services/AppUserServices/AppUserService02.dart';
import 'package:scrapper/Services/GeoLocatorService/GeoLocator02.dart';

import '../GeoLocatorService/GeoLocator03.dart';
import '../OSRMServices/OSRMService01.dart';

class OrderService04 extends ChangeNotifier {
  OrderService04(this.geo);

  late GeoLocator03 geo;

  StreamSubscription<DocumentSnapshot<Order01>>? _sub;
  Timer? _timer;

  Order01? _order;
  Order01? get order => _order;
  String? _orderId;

  CollectionReference<Order01> get _ref => FirebaseFirestore.instance
      .collection('order01')
      .withConverter(
        fromFirestore: Order01.fromFirestore,
        toFirestore: (model, _) => model.toJson(),
      );

  /// This setter is needed
  void updateGeo(GeoLocator03 newGeo) {
    geo.removeListener(_onLocationUpdate);
    geo = newGeo;
    if (_orderId != null) geo.addListener(_onLocationUpdate);
  }

  void init(String orderId) {
    stop();

    _orderId = orderId;

    _sub = _ref.doc(orderId).snapshots().listen((doc) async {
      if (!doc.exists) return;

      final data = doc.data();
      if (data == null) return;

      _order = data;
      notifyListeners();

      await _attachDistance();
    });

    geo.addListener(_onLocationUpdate);
  }

  void _onLocationUpdate() {
    if (_order == null) return;

    _attachDistance();
  }

  Future<void> _attachDistance() async {
    if (_order == null) return;

    final current = geo.currentLatLng;
    if (current == null) return;

    final data = await OSRMService01().getRouteGeoJson(
      current,
      _order!.address.latLng,
    );

    _order?.routesRes = data;
    notifyListeners();

    _updateFirestore(current);
  }

  void _updateFirestore(LatLng current) {
    if (_orderId == null || _order == null) return;
    if (_order!.status != Order01Status.assigned) return;

    _timer?.cancel();

    _timer = Timer(const Duration(seconds: 30), () {
      _ref.doc(_orderId!).update({
        'sanitarian.currLocation': GeoPoint(
          current.latitude,
          current.longitude,
        ),
      });
    });
  }

  Future<void> cancelCurrOrder() async {
    if (_orderId == null) return;

    await _ref.doc(_orderId!).update({
      'status': Order01Status.requested.name,
      'sanitarian': null,
    });
  }

  Future<void> completeCurrOrder() async {
    if (_orderId == null) return;
    await _ref.doc(_orderId!).update({'status': Order01Status.completed.name});
  }

  void _updateOrder(Order01? order) {
    order = order;
    notifyListeners();
  }

  void stop() {
    _sub?.cancel();
    _timer?.cancel();
    geo.removeListener(_onLocationUpdate);

    _sub = null;
    _orderId = null;
    _order = null;

    notifyListeners();
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
