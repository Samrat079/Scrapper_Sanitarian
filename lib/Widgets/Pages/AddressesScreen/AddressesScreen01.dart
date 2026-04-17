import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scrapper/Models/Address/Address02.dart';
import 'package:scrapper/Models/Customer/Customer01.dart';
import 'package:scrapper/Services/AddressServices/Address02Services.dart';
import 'package:scrapper/Widgets/Custome/CenterColumn/CenterColumn04.dart';
import 'package:scrapper/Widgets/Pages/AddressesScreen/Widget/AddressTile02.dart';

class AddressesScreen01 extends StatelessWidget {
  final Customer01 customer;

  const AddressesScreen01({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    final add2Service = Address02Services(customer.uid);
    void addAddress()async{
      final address = await Navigator.pushNamed(context, '/location01');
      if (address == null || address is! Address02) return;
      add2Service.add(address);
    }
    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder<QuerySnapshot<Address02>>(
        stream: add2Service.getRealTime(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;

          return CenterColumn04(
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
                onPressed: addAddress,
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
