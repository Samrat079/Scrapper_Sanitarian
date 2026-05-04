import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:latlong2/latlong.dart';
import 'package:scrapper/Models/Orders/Order01.dart';

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

  void _updateFirestore(LatLng current) {
    if (_orderId == null || _order == null) return;
    if (_order!.status != Order01Status.assigned) return;

    _timer?.cancel();

    _timer = Timer(const Duration(seconds: 30), () {
      debugPrint("updating firestore");
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

  Future<void> _attachDistance() async {
    if (_order == null) return;

    final current = geo.currentLatLng;
    if (current == null) return;

    final shouldRefetch = _shouldRefetch(_order!, current);
    if (!shouldRefetch) {
      notifyListeners();
      return;
    }
    debugPrint("calling osrm");
    final data = await OSRMService01().getRouteGeoJson(
      current,
      _order!.address.latLng,
    );
    _order?.routesRes = data;
    notifyListeners();

    _updateFirestore(current);
  }

  bool _shouldRefetch(Order01 order, LatLng current) {
    final coords = order.routesRes.coordinates;
    if (coords.length < 2) return true;

    double minDistance = double.infinity;
    int closestIndex = 0;

    for (int i = 0; i < coords.length - 1; i++) {
      final d = _distanceToSegment(current, coords[i], coords[i + 1]);

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
    return true;
  }

  double _distanceToSegment(LatLng p, LatLng v, LatLng w) {
    final l2 = Distance().as(LengthUnit.Meter, v, w);
    if (l2 == 0) return Distance().as(LengthUnit.Meter, p, v);

    final t =
        ((p.latitude - v.latitude) * (w.latitude - v.latitude) +
            (p.longitude - v.longitude) * (w.longitude - v.longitude)) /
        (l2 * l2);

    final tClamped = t.clamp(0.0, 1.0);

    final projection = LatLng(
      v.latitude + (w.latitude - v.latitude) * tClamped,
      v.longitude + (w.longitude - v.longitude) * tClamped,
    );

    return Distance().as(LengthUnit.Meter, p, projection);
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
