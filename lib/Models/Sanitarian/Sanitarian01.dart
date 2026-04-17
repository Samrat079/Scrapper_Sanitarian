import 'package:cloud_firestore/cloud_firestore.dart';

class Sanitarian01 {
  final String uid, displayName, phoneNumber, email, photoUrl;
  final Timestamp createdAt;

  Sanitarian01({
    required this.uid,
    required this.displayName,
    required this.phoneNumber,
    required this.email,
    required this.createdAt,
    required this.photoUrl,
  });

  factory Sanitarian01.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) => Sanitarian01(
    uid: snapshot.id,
    displayName: snapshot.data()!['displayName'] ?? 'client default value',
    phoneNumber: snapshot.data()!['phoneNumber'] ?? 'client default value',
    email: snapshot.data()!['email'] ?? 'client default value',
    createdAt: snapshot.data()!['createdAt'] ?? Timestamp.now(),
    photoUrl: snapshot.data()!['photoUrl'],
  );

  factory Sanitarian01.fromJson(Map<String, dynamic> json) => Sanitarian01(
    uid: json['uid'],
    displayName: json['displayName'] ?? 'client default value',
    phoneNumber: json['phoneNumber'] ?? 'client default value',
    email: json['email'] ?? 'client default value',
    createdAt: json['createdAt'],
    photoUrl: json['photoUrl'],
  );

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'displayName': displayName,
    'phoneNumber': phoneNumber,
    'email': email,
    'photoUrl': photoUrl,
    'createdAt': createdAt,
  };
}
