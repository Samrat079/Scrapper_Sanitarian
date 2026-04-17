import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scrapper/Services/AddressServices/Address01Services.dart';

import '../../../../Models/Address/Address01.dart';

class AddressTile01 extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  final Address01Services addService;
  const AddressTile01({super.key, required this.doc, required this.addService});

  @override
  Widget build(BuildContext context) {
    final address = Address01.fromJson(
      doc.data() as Map<String, dynamic>,
    );
    return ListTile(
      title: Text(address.houseNumber),
      subtitle: Text(address.locality),
      trailing: IconButton(
        onPressed: () => addService.deleteById(doc.id),
        icon: Icon(Icons.delete_outline),
      ),
    );
  }
}
