import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../Models/Orders/Order01.dart';
import '../AppUserServices/AppUserService03.dart';

class OrderListService04 extends ChangeNotifier {
  OrderListService04({required AppUserService03 appUser}) : _appUser = appUser;

  /// 🔗 Dependency
  late AppUserService03 _appUser;

  void updateDependencies(AppUserService03 appUser) {
    if (_appUser.current.uid == appUser.current.uid) return;

    _appUser = appUser;
    _restart();
  }

  final CollectionReference<Order01> _ref = FirebaseFirestore.instance
      .collection('order01')
      .withConverter<Order01>(
        fromFirestore: Order01.fromFirestore,
        toFirestore: (model, _) => model.toJson(),
      );

  StreamSubscription<QuerySnapshot<Order01>>? _sub;

  List<Order01> _orders = [];

  List<Order01> get orders => _orders;

  /// 🚀 Start / restart
  void init() {
    _restart();
  }

  void _restart() {
    _sub?.cancel();

    final uid = _appUser.current.uid;
    print("Uid: " + uid.toString());
    if (uid == null) {
      _orders = [];
      notifyListeners();
      return;
    }

    _sub = _ref.where('sanitarian.uid', isEqualTo: uid).snapshots().listen((
      snapshot,
    ) {
      _orders = snapshot.docs.map((e) => e.data()).toList();
      notifyListeners();
    });
  }

  void stop() {
    _sub?.cancel();
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
