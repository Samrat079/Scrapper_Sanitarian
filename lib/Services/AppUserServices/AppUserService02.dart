import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:scrapper/Models/AppUser/AppUser02.dart';
import 'package:scrapper/Models/Sanitarian/Sanitarian01.dart';
import 'package:scrapper/Services/OrderServices/CurrOrderService01.dart';
import 'package:scrapper/Services/OrderServices/Order01Service02.dart';

class AppUserService02 extends ValueNotifier<AppUser02> {
  /// is a singleton but only for having the current value
  static final AppUserService02 _instance = AppUserService02._internal();

  AppUserService02._internal() : super(AppUser02(auth: null, sanitarian: null));

  factory AppUserService02() => _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final CollectionReference<Sanitarian01> _users = FirebaseFirestore.instance
      .collection('sanitarians')
      .withConverter<Sanitarian01>(
        fromFirestore: Sanitarian01.fromFirestore,
        toFirestore: (Sanitarian01 c, _) => c.toJson(),
      );

  String? _verificationId;

  User? _authUser;
  Sanitarian01? _sanitarian;

  AppUser02 get current => AppUser02(auth: _authUser, sanitarian: _sanitarian);
  bool get isLoggedIn => _authUser != null && _sanitarian != null;
  bool get exists => current.exists;

  /// init
  Future<void> init() async {
    _auth.authStateChanges().listen((user) async {
      _authUser = user;

      if (user == null) {
        _sanitarian = null;
        value = current;
        return;
      }

      final doc = await _users.doc(user.uid).get();
      _sanitarian = doc.exists ? doc.data() : null;
      value = current;

      /// listeners
      if (isLoggedIn) {
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

    value = current;
    Order01Service02().init();
    return current;
  }

  Future<void> updateAppUser(String displayName) async {
    await _authUser?.updateDisplayName(displayName);
    await _authUser?.reload();
    _authUser = _auth.currentUser;
    await _users.doc(current.uid).update({'displayName': displayName});
    _sanitarian?.displayName = displayName;
    value = current;
  }


  /// Get user by ID
  Future<Sanitarian01> getUserById(String uid) async {
    final doc = await _users.doc(uid).get();
    return doc.data()!;
  }

  /// 🚪 Logout
  Future<void> logout() async {
    await _auth.signOut();
    _authUser = null;
    _sanitarian = null;
    value = current;

    Order01Service02().stop();
  }

  /// Delete user
  Future<void> delete() async {
    await _users.doc(_authUser?.uid).delete();
    await _authUser?.delete();
  }
}
