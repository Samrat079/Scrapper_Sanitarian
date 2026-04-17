import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scrapper/Models/Address/Address02.dart';
import 'package:scrapper/Services/AddressServices/Address02Services.dart';


class AddressTile02 extends StatelessWidget {
  final QueryDocumentSnapshot<Address02> doc;
  final Address02Services addService;

  const AddressTile02({super.key, required this.doc, required this.addService});

  @override
  Widget build(BuildContext context) {
    final address = doc.data();
    return ListTile(
      title: Text(address.place.name.toString()),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            address.place.displayName.toString(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(address.phoneNumber)
        ],
      ),
      trailing: IconButton(
        onPressed: () => addService.deleteById(doc.id),
        icon: Icon(Icons.delete_outline),
      ),
    );
  }
}
