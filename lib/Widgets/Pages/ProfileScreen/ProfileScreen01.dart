import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:scrapper/Services/AppUserServices/AppUserServices01.dart';
import 'package:scrapper/Widgets/Custome/CardList01/CardList01.dart';
import 'package:scrapper/theme/theme_extensions.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../Custome/CenterColumn/CenterColumn04.dart';

class ProfileScreen01 extends StatelessWidget {
  const ProfileScreen01({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ValueListenableBuilder(
        valueListenable: AppUserServices01(),
        builder: (context, appUser, _) {
          final customer = appUser.customer01;

          if (customer == null) {
            return const Center(child: Text('Not logged in'));
          }

          return CenterColumn04(
            children: [
              context.gapMD,

              /// User profile section
              Row(
                children: [
                  CachedNetworkImage(
                    imageUrl: customer.photoUrl,
                    imageBuilder: (context, imageProvider) => CircleAvatar(
                      radius: 54,
                      backgroundImage: imageProvider,
                    ),
                    placeholder: (context, url) => const CircleAvatar(
                      radius: 54,
                      child: Icon(Icons.person_outline),
                    ),
                  ),
                  context.gapMD,

                  Text(
                    customer.displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              context.gapXL,

              /// User customer card
              CardList01(
                children: [
                  ListTile(
                    leading: const Icon(Icons.phone_outlined),
                    title: const Text('Phone number'),
                    subtitle: Text(customer.phoneNumber),
                  ),
                  ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: const Text('Email'),
                    subtitle: Text(customer.email),
                  ),
                  ListTile(
                    leading: const Icon(Icons.timer_outlined),
                    title: const Text('Member since'),
                    subtitle: Text(timeago.format(customer.createdAt.toDate())),
                  ),
                ],
              ),

              /// My orders card
              CardList01(
                children: [
                  const ListTile(
                    title: Text('My Orders'),
                    leading: Icon(Icons.book_outlined),
                    trailing: Icon(Icons.arrow_forward_ios_outlined),
                  ),
                  ListTile(
                    title: const Text('Saved address'),
                    leading: const Icon(Icons.house_outlined),
                    trailing: const Icon(Icons.arrow_forward_ios_outlined),
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
                  const ListTile(
                    leading: Icon(Icons.edit_outlined),
                    title: Text('Edit Profile'),
                    trailing: Icon(Icons.arrow_forward_ios_outlined),
                  ),
                  ListTile(
                    textColor: Theme.of(context).colorScheme.error,
                    iconColor: Theme.of(context).colorScheme.error,
                    leading: const Icon(Icons.logout_outlined),
                    title: const Text('Logout'),
                    onTap: () async {
                      await AppUserServices01().logout();
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    textColor: Theme.of(context).colorScheme.error,
                    iconColor: Theme.of(context).colorScheme.error,
                    leading: const Icon(Icons.delete_outline),
                    title: const Text('Delete profile'),
                    onTap: () => AppUserServices01().delete(),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
