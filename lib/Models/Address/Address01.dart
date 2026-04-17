class Address01 {
  // final String? id;
  final String name, phoneNumber, houseNumber, locality;
  final bool isDefault;

  Address01({
    // this.id,
    required this.name,
    required this.phoneNumber,
    required this.houseNumber,
    required this.locality,
    required this.isDefault,
  });

  factory Address01.fromJson(Map<String, dynamic> json) {
    return Address01(
      // uid: json['uid'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      houseNumber: json['houseNumber'],
      locality: json['locality'],
      isDefault: json['isDefault'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'uid': uid,
      'name': name,
      'phoneNumber': phoneNumber,
      'houseNumber': houseNumber,
      'locality': locality,
      'isDefault': isDefault,
    };
  }
}
