import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:scrapper/Models/Customer/Customer01.dart';
import 'package:scrapper/Models/AppUser/AppUser01.dart';
import 'package:scrapper/Services/OrderServices/Order01Service.dart';
import 'package:scrapper/Services/OrderServices/Order01Service02.dart';

class AppUserServices01 extends ValueNotifier<AppUser01> {
  /// 🔒 Singleton
  static final AppUserServices01 _instance =
  AppUserServices01._internal();

  AppUserServices01._internal() : super(AppUser01(auth: null, customer01: null));

  factory AppUserServices01() => _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final CollectionReference<Customer01> _users =
  FirebaseFirestore.instance
      .collection('customers')
      .withConverter<Customer01>(
    fromFirestore: Customer01.fromFirestore,
    toFirestore: (Customer01 c, _) => c.toJson(),
  );

  String? _verificationId;

  User? _authUser;
  Customer01? _customer;

  AppUser01 get current =>
      AppUser01(auth: _authUser, customer01: _customer);

  bool get isLoggedIn =>
      _authUser != null && _customer != null;

  bool get isReady => current.exists;

  /// init
  Future<void> init() async {
    _auth.authStateChanges().listen((user) async {
      _authUser = user;

      if (user == null) {
        _customer = null;
        value = current;
        return;
      }

      final doc = await _users.doc(user.uid).get();

      _customer = doc.exists ? doc.data() : null;

      value = current;

      /// listeners
      if (isLoggedIn) {
        Order01Service().init();
        Order01Service02().init();
      }
    });
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

  /// 🔐 Verify OTP
  Future<AppUser01> verifyOtp(String otp) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: otp,
    );

    final result = await _auth.signInWithCredential(credential);
    final user = result.user!;

    _authUser = user;

    final doc = await _users.doc(user.uid).get();

    if (!doc.exists) {
      final newCustomer = Customer01.fromAuth(user);

      await _users.doc(user.uid).set(
        newCustomer,
        SetOptions(merge: true),
      );

      _customer = newCustomer;
    } else {
      _customer = doc.data();
    }

    value = current;
    Order01Service().init();
    Order01Service02().init();
    return current;
  }

  /// 👤 Get user by ID
  Future<Customer01> getUserById(String uid) async {
    final doc = await _users.doc(uid).get();
    return doc.data()!;
  }

  /// 🚪 Logout
  Future<void> logout() async {
    await _auth.signOut();

    _authUser = null;
    _customer = null;

    value = current;

    Order01Service().dispose();
    Order01Service02().dispose();
  }

  /// ❌ Delete user
  Future<void> delete() async {
    await _users.doc(_authUser?.uid).delete();
    await _authUser?.delete();
  }
}