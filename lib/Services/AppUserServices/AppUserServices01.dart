import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scrapper/Models/Customer/Customer01.dart';
import 'package:scrapper/Models/AppUser/AppUser01.dart';

class AppUserServices01 {
  static final AppUserServices01 _instance = AppUserServices01._internal();

  AppUserServices01._internal();

  factory AppUserServices01() => _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference<Customer01> _users = FirebaseFirestore.instance
      .collection('customers')
      .withConverter<Customer01>(
        fromFirestore: Customer01.fromFirestore,
        toFirestore: (Customer01 customer, _) => customer.toJson(),
      );

  String? _verificationId;

  User? _authUser;
  Customer01? _customer;

  /// =========================
  /// APP USER (SINGLE SOURCE)
  /// =========================

  AppUser01 get current => AppUser01(auth: _authUser, customer01: _customer);

  bool get isLoggedIn => current.auth != null && current.customer01 != null;

  bool get isReady => current.exists;

  /// =========================
  /// STREAM (REACTIVE UI)
  /// =========================

  final StreamController<AppUser01> _controller =
      StreamController<AppUser01>.broadcast();

  Stream<AppUser01> get stream => _controller.stream;

  /// =========================
  /// INIT (SYNC AUTH + PROFILE)
  /// =========================

  Future<void> init() async {
    _auth.authStateChanges().listen((user) async {
      _authUser = user;

      if (user == null) {
        _customer = null;
        _controller.add(current);
        return;
      }

      final doc = await _users.doc(user.uid).get();

      if (doc.exists) {
        _customer = doc.data();
      } else {
        _customer = null;
      }

      _controller.add(current);
    });
  }

  /// =========================
  /// OTP LOGIN
  /// =========================

  Future<void> sendOtp(String number) async {
    final Completer<void> completer = Completer();

    await _auth.verifyPhoneNumber(
      phoneNumber: number,
      verificationCompleted: (PhoneAuthCredential cred) async {
        await _auth.signInWithCredential(cred);
        completer.complete();
      },
      verificationFailed: (FirebaseAuthException e) {
        completer.completeError(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        completer.complete();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );

    return completer.future;
  }

  /// =========================
  /// VERIFY OTP + CREATE/FETCH USER
  /// =========================

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

      await _users
          .doc(user.uid)
          .set(newCustomer, SetOptions(merge: true));
      _customer = newCustomer;
    } else {
      _customer = doc.data();
    }
    final appUser = current;
    _controller.add(appUser);

    return appUser;
  }

  /// =========================
  /// GET OTHER USERS
  /// =========================

  Future<Customer01> getUserById(String uid) async {
    final doc = await _users.doc(uid).get();
    return doc.data()!;
  }

  /// =========================
  /// LOGOUT
  /// =========================

  Future<void> logout() async {
    await _auth.signOut();
    _authUser = null;
    _customer = null;

    _controller.add(current);
  }

  /// ==================
  /// Delete profile
  /// ===============
  Future<void> delete() async {
    _users.doc(_authUser?.uid).delete();
    _authUser?.delete();
  }
}
