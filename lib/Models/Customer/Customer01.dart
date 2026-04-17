import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Customer01 {
  final String uid, displayName, phoneNumber, email, photoUrl;
  final Timestamp createdAt;

  Customer01({
    required this.uid,
    required this.displayName,
    required this.phoneNumber,
    required this.email,
    required this.createdAt,
    required this.photoUrl,
  });

  factory Customer01.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return Customer01(
      uid: snapshot.id,
      displayName: data['displayName'] ?? 'anonymous',
      phoneNumber: data['phoneNumber'] ?? 'Number not added',
      email: data['email'] ?? 'Email not verified',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      photoUrl:
          data['photoUrl'] ??
          'https://placehold.co/256x256/darkgreen/white.png?text=test',
    );
  }

  factory Customer01.fromJson(Map<String, dynamic> json) {
    return Customer01(
      uid: json['uid'],
      displayName: json['displayName'] ?? 'Username not added',
      phoneNumber: json['phoneNumber'] ?? 'Phone number not verified',
      email: json['email'] ?? 'Email not varified',
      createdAt: json['createdAt'] ?? Timestamp.now(),
      photoUrl:
          json['photoUrl'] ??
          'https://placehold.co/256x256/darkgreen/white.png?text=test',
    );
  }

  factory Customer01.fromAuth(User user) {
    return Customer01(
      uid: user.uid,
      displayName: user.displayName ?? 'anonymous',
      phoneNumber: user.phoneNumber ?? 'Phone number not verified',
      email: user.email ?? 'Email not verified',
      photoUrl:
          user.photoURL ??
          'https://placehold.co/256x256/darkgreen/white.png?text=test',
      createdAt: user.metadata.creationTime != null
          ? Timestamp.fromDate(user.metadata.creationTime!)
          : Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'email': email,
      'createdAt': createdAt,
      'photoUrl': photoUrl,
    };
  }
}
