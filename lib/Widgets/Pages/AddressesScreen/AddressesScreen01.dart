import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scrapper/Models/Address/Address02.dart';
import 'package:scrapper/Models/Customer/Customer01.dart';
import 'package:scrapper/Services/AddressServices/Address01Services.dart';
import 'package:scrapper/Services/AddressServices/Address02Services.dart';
import 'package:scrapper/Widgets/Custome/CenterColumn/ScrollColumn01.dart';
import 'package:scrapper/Widgets/Pages/AddressesScreen/Widget/AddressTile02.dart';

import '../../../Models/Address/Address01.dart';
import 'Widget/AddressTile01.dart';

class AddressesScreen01 extends StatelessWidget {
  final Customer01 customer;

  const AddressesScreen01({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    final add2Service = Address02Services(customer.uid);
    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder<QuerySnapshot<Address02>>(
        stream: add2Service.getRealTime(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;

          return ScrollColumn01(
            children: [
              /// List of addresses
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  return AddressTile02(
                    doc: docs[index],
                    addService: add2Service,
                  );
                },
              ),

              /// Add more
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: () =>
                    Navigator.pushNamed<Address02>(context, '/location01').then(
                      (result) => {if (result != null) add2Service.add(result)},
                    ),
                label: Text('Add address'),
                icon: Icon(Icons.add_outlined),
              ),
            ],
          );
        },
      ),
    );
  }
}
