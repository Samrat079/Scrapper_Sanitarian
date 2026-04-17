import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scrapper/Models/Customer/Customer01.dart';

import '../AuthServices/AuthServices.dart';

class Customer01Services {
  static final Customer01Services _instance = Customer01Services._internal();

  Customer01Services._internal();

  factory Customer01Services() {
    return _instance;
  }

  Customer01? _customer;

  final CollectionReference _users = FirebaseFirestore.instance.collection(
    'customers',
  );

  // Future<void> init() async {
  //   final doc = await _users.doc(AuthServices().currUser?.uid).get();
  //   if (!doc.exists) return;
  //   _customer = Customer01.fromJson(doc.data() as Map<String, dynamic>);
  //   return;
  // }

  Future<void> createUser(Customer01 user) async {
    _customer = user;
    return await _users
        .doc(user.uid)
        .set(user.toJson(), SetOptions(merge: true));
  }

  Future<void> testUser() async {
    return await _users
        .add({'hello': 'wporld'})
        .then((value) => print('added$value'));
  }

  Future<Customer01> getUserById(String uid) async {
    return await _users
        .doc(uid)
        .get()
        .then((e) => Customer01.fromJson(e.data() as Map<String, dynamic>));
  }

  Customer01? get currCustomer => _customer;
}
