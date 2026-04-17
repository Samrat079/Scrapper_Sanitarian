import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:scrapper/Models/Customer/Customer01.dart';
import 'package:scrapper/Services/AppUserServices/AppUserServices01.dart';
import 'package:scrapper/Services/CustomerServices/CustomerServices01.dart';
import 'package:scrapper/Widgets/Custome/CardList01/CardList01.dart';
import 'package:scrapper/Widgets/Custome/CenterColumn/ScrollColumn01.dart';
import 'package:scrapper/Widgets/Custome/FutureBuilder01/FutureBuilder01.dart';
import 'package:timeago/timeago.dart' as timeago;

class ProfileScreen01 extends StatelessWidget {
  final Customer01 customer;

  const ProfileScreen01({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ScrollColumn01(
        children: [
          /// User profile section
          Row(
            spacing: 12,
            children: [
              /// Profile image
              CachedNetworkImage(
                imageUrl: customer.photoUrl,
                imageBuilder: (context, imageProvider) =>
                    CircleAvatar(radius: 30, backgroundImage: imageProvider),
                placeholder: (context, url) =>
                    CircleAvatar(radius: 30, child: Icon(Icons.person_outline)),
              ),

              Text(
                customer.displayName,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          /// User customer card
          CardList01(
            children: [
              ListTile(
                leading: Icon(Icons.phone_outlined),
                title: Text('Phone number'),
                subtitle: Text(customer.phoneNumber),
                // trailing: Icon(Icons.edit_outlined),
              ),
              ListTile(
                leading: Icon(Icons.email_outlined),
                title: Text('Email'),
                subtitle: Text(customer.email),
                // trailing: Icon(Icons.edit_outlined),
              ),
              ListTile(
                leading: Icon(Icons.timer_outlined),
                title: Text('Member since'),
                subtitle: Text(timeago.format(customer.createdAt.toDate())),
              ),
            ],
          ),

          ///My orders card
          CardList01(
            children: [
              ListTile(
                title: Text('My Orders'),
                leading: Icon(Icons.book_outlined),
                trailing: Icon(Icons.arrow_forward_ios_outlined),
              ),
              ListTile(
                title: Text('Saved address'),
                leading: Icon(Icons.house_outlined),
                trailing: Icon(Icons.arrow_forward_ios_outlined),
                onTap: () => Navigator.pushNamed(
                  context,
                  '/addresses',
                  arguments: customer,
                ),
              ),
            ],
          ),

          /// Profile options
          CardList01(
            children: [
              ListTile(
                leading: Icon(Icons.edit_outlined),
                title: Text('Edit Profile'),
                trailing: Icon(Icons.arrow_forward_ios_outlined),
              ),
              ListTile(
                textColor: Theme.of(context).colorScheme.error,
                iconColor: Theme.of(context).colorScheme.error,
                leading: Icon(Icons.logout_outlined),
                title: Text('Logout'),
                onTap: () => AppUserServices01().logout().then(
                  (_) => Navigator.pop(context),
                ),
              ),
              ListTile(
                textColor: Theme.of(context).colorScheme.error,
                iconColor: Theme.of(context).colorScheme.error,
                leading: Icon(Icons.delete_outline),
                title: Text('Delete profile'),
                onTap: () => AppUserServices01().delete(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
