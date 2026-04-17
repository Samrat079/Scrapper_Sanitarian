import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:scrapper/Services/AppUserServices/AppUserService02.dart';
import 'package:scrapper/Services/AppUserServices/AppUserService02.dart';
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
        valueListenable: AppUserService02(),
        builder: (context, appUser, _) {
          final sanitarian = appUser.sanitarian;

          if (sanitarian == null) {
            return const Center(child: Text('Not logged in'));
          }

          return CenterColumn04(
            children: [
              context.gapMD,

              /// Sanitarian profile section
              Row(
                children: [
                  CachedNetworkImage(
                    imageUrl: sanitarian.photoUrl,
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
                    sanitarian.displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              context.gapXL,

              /// User sanitarian card
              CardList01(
                children: [
                  ListTile(
                    leading: const Icon(Icons.phone_outlined),
                    title: const Text('Phone number'),
                    subtitle: Text(sanitarian.phoneNumber),
                  ),
                  ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: const Text('Email'),
                    subtitle: Text(sanitarian.email),
                  ),
                  ListTile(
                    leading: const Icon(Icons.timer_outlined),
                    title: const Text('Member since'),
                    subtitle: Text(timeago.format(sanitarian.createdAt.toDate())),
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
                    textColor: context.colorScheme.error,
                    iconColor: context.colorScheme.error,
                    leading: const Icon(Icons.logout_outlined),
                    title: const Text('Logout'),
                    onTap: () async {
                      await AppUserService02().logout();
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    textColor: context.colorScheme.error,
                    iconColor: context.colorScheme.error,
                    leading: const Icon(Icons.delete_outline),
                    title: const Text('Delete profile'),
                    onTap: () => AppUserService02().delete(),
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
