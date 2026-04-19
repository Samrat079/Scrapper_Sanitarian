import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scrapper/Models/Address/Address02.dart';
import 'package:scrapper/Models/Customer/Customer01.dart';
import 'package:scrapper/Models/Sanitarian/Sanitarian01.dart';

class Order01 {
  String? uid;
  double price;
  Address02 address;
  Customer01 customer;
  Sanitarian01? sanitarian;
  Order01Status status;
  Timestamp createdAt;
  double? distance;

  Order01({
    this.uid,
    required this.price,
    required this.address,
    required this.customer,
    this.sanitarian,
    this.status = Order01Status.requested,
    required this.createdAt,
    this.distance = 0.0,
  });

  factory Order01.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) => Order01(
    uid: snapshot.id,
    price: snapshot.data()!['price'],
    address: Address02.fromJson(snapshot.data()!['address']),
    customer: Customer01.fromJson(snapshot.data()!['customer']),
    status: Order01Status.values.firstWhere(
      (e) => e.name == snapshot.data()!['status'],
    ),
    sanitarian: snapshot.data()!['sanitarian'],
    createdAt: snapshot.data()!['createdAt'],
  );


  Map<String, dynamic> toJson() => {
    'price': price,
    'address': address.toJson(),
    'customer': customer.toJson(),
    'createdAt': createdAt,
    'status': status.name,
    'sanitarian': sanitarian?.toJson(),
  };
}

enum Order01Status { requested, assigned, completed, cancelled, expired }
