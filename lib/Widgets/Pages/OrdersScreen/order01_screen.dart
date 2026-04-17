import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scrapper/Models/Orders/Order01.dart';
import 'package:scrapper/Services/OrderServices/Order01Service.dart';
import 'package:scrapper/Services/OrderServices/Order01Service02.dart';

class Order01Screen extends StatelessWidget {
  const Order01Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ValueListenableBuilder<List<Order01>>(
        valueListenable: Order01Service02(),
        builder: (context, orders, _) {
          if (orders.isEmpty) return Center(child: Text('Nothing to see here'));
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final data = orders[index];
              return ListTile(
                title: Text(data.price.toString()),
                subtitle: Text(data.address.place.displayName.toString()),
                trailing: IconButton(
                  onPressed: () => Order01Service02().rejectById(index),
                  icon: Icon(Icons.cancel_outlined),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
