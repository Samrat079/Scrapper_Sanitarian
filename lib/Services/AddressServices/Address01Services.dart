import 'package:cloud_firestore/cloud_firestore.dart';

import '../../Models/Address/Address01.dart';

class Address01Services {
  final String uid;

  Address01Services(this.uid);

  CollectionReference get _address => FirebaseFirestore.instance
      .collection('customers')
      .doc(uid)
      .collection('addresses');

  Future<void> add(Address01 address01) => _address.add(address01.toJson());

  Future<List<Address01>> get() async {
    final snapshot = await _address.get();
    return snapshot.docs
        .map((i) => Address01.fromJson(i.data() as Map<String, dynamic>))
        .toList();
  }

  Stream<QuerySnapshot> getRealTime() => _address.snapshots();

  void deleteById(String uid) => _address.doc(uid).delete();
}
