import 'package:firebase_auth/firebase_auth.dart';
import 'package:scrapper/Models/Sanitarian/Sanitarian01.dart';

class AppUser02 {
  final User? auth;
  final Sanitarian01? sanitarian;

  AppUser02({required this.auth, required this.sanitarian});

  bool get exists => auth != null && sanitarian != null;

  String? get uid => auth?.uid;
}
