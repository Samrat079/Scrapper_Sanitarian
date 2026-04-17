import 'package:firebase_auth/firebase_auth.dart';
import 'package:scrapper/Models/Customer/Customer01.dart';

class AppUser01 {
  final User? auth;
  final Customer01? customer01;

  AppUser01({required this.auth, required this.customer01});

  bool get exists => auth != null && customer01 != null;

  String? get uid => auth?.uid;
}
