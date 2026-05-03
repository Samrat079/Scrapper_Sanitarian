import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:scrapper/Models/AppUser/AppUser02.dart';
import 'package:scrapper/Models/Sanitarian/Sanitarian01.dart';

import '../GeoLocatorService/GeoLocator03.dart';
import '../OrderServices/OrderListService03.dart';
import '../OrderServices/OrderService04.dart';

class AppUserService03 extends ChangeNotifier {
  AppUserService03({
    required GeoLocator03 geo,
    required OrderListService03 orderList,
    required OrderService04 orderService,
  }) : _geo = geo,
       _orderList = orderList,
       _orderService = orderService {
    _authSub = _auth.authStateChanges().listen(_onAuthChanged);
  }

  /// ✅ Dependencies (mutable for ProxyProvider)
  late GeoLocator03 _geo;
  late OrderListService03 _orderList;
  late OrderService04 _orderService;

  /// 🔥 Dependency updater (REQUIRED)
  void updateDependencies(
    GeoLocator03 geo,
    OrderListService03 orderList,
    OrderService04 orderService,
  ) {
    _geo = geo;
    _orderList = orderList;
    _orderService = orderService;
  }

  /// Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final CollectionReference<Sanitarian01> _users = FirebaseFirestore.instance
      .collection('sanitarians')
      .withConverter<Sanitarian01>(
        fromFirestore: Sanitarian01.fromFirestore,
        toFirestore: (Sanitarian01 c, _) => c.toJson(),
      );

  /// State
  String? _verificationId;
  User? _authUser;
  Sanitarian01? _sanitarian;

  StreamSubscription<User?>? _authSub;

  /// Public getters
  AppUser02 get current => AppUser02(auth: _authUser, sanitarian: _sanitarian);

  bool get isLoggedIn => _authUser != null && _sanitarian != null;

  bool get exists => current.exists;

  /// 🔥 Auth state handler
  Future<void> _onAuthChanged(User? user) async {
    _authUser = user;

    if (user == null) {
      _sanitarian = null;

      /// stop all services
      _orderList.stop();
      _orderService.stop();

      notifyListeners();
      return;
    }

    final doc = await _users.doc(user.uid).get();
    _sanitarian = doc.exists ? doc.data() : null;

    notifyListeners();

    if (isLoggedIn) {
      await _geo.init();

      /// 🔥 start order list automatically
      _orderList.init();
      _orderList.checkActiveOrder(current.uid!);
    }
  }

  /// 📲 Send OTP
  Future<void> sendOtp(String number) async {
    final completer = Completer<void>();

    await _auth.verifyPhoneNumber(
      phoneNumber: number,
      verificationCompleted: (cred) async {
        await _auth.signInWithCredential(cred);
        completer.complete();
      },
      verificationFailed: (e) => completer.completeError(e),
      codeSent: (verificationId, _) {
        _verificationId = verificationId;
        completer.complete();
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
      },
    );

    return completer.future;
  }

  /// ✅ Verify OTP
  Future<AppUser02> verifyOtp(String otp) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: otp,
    );

    final result = await _auth.signInWithCredential(credential);
    final user = result.user!;
    _authUser = user;

    final doc = await _users.doc(user.uid).get();

    if (!doc.exists) {
      final newSanitarian = Sanitarian01.fromAuth(user);
      await _users.doc(user.uid).set(newSanitarian, SetOptions(merge: true));
      _sanitarian = newSanitarian;
    } else {
      _sanitarian = doc.data();
    }

    notifyListeners();

    await _geo.init();
    _orderList.init();

    return current;
  }

  /// Update profile
  Future<void> updateAppUser(String displayName) async {
    await _authUser?.updateDisplayName(displayName);
    await _authUser?.reload();

    _authUser = _auth.currentUser;

    await _users.doc(current.uid).update({'displayName': displayName});

    _sanitarian?.displayName = displayName;

    notifyListeners();
  }

  /// 🚪 Logout
  Future<void> logout() async {
    await _auth.signOut();
    // cleanup handled in _onAuthChanged
  }

  /// Delete user
  Future<void> delete() async {
    await _users.doc(_authUser?.uid).delete();
    await _authUser?.delete();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
