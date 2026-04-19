import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    displayName: snapshot.data()!['displayName'] ?? 'anonymous',
    phoneNumber: snapshot.data()!['phoneNumber'] ?? 'Number not added',
    email: snapshot.data()!['email'] ?? 'Email not verified',
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

  factory Sanitarian01.fromAuth(User user) => Sanitarian01(
    uid: user.uid,
    displayName: user.displayName ?? 'anonymous',
    phoneNumber: user.phoneNumber ?? 'Phone number not verified',
    email: user.email ?? 'Email not varified',
    createdAt: user.metadata.creationTime != null
        ? Timestamp.fromDate(user.metadata.creationTime!)
        : Timestamp.now(),
    photoUrl:
        user.photoURL ??
        'https://placehold.co/256x256/darkgreen/white.png?text=test',
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
