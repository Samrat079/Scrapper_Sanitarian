import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scrapper/Models/Address/Address02.dart';

class Address02Services {
  final String uid;

  Address02Services(this.uid);

  CollectionReference<Address02> get _ref => FirebaseFirestore.instance
      .collection('customers')
      .doc(uid)
      .collection('addresses02')
      .withConverter<Address02>(
        fromFirestore: Address02.fromFirestore,
        toFirestore: (model, _) => model.toJson(),
      );

  Future<DocumentReference<Object?>> add(Address02 address02) =>
      _ref.add(address02);

  Stream<QuerySnapshot<Address02>> getRealTime() => _ref.snapshots();

  void deleteById(String uid) => _ref.doc(uid).delete();
}
