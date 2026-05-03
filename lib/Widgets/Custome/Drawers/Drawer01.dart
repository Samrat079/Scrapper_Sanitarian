import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:scrapper/Services/AppUserServices/AppUserService02.dart';

import '../../../Services/AppUserServices/AppUserService03.dart';
import '../../../theme/theme_extensions.dart';

class Drawer01 extends StatelessWidget {
  const Drawer01({super.key});

  @override
  Widget build(BuildContext context) {
    // final appUserService = AppUserService02();
    final appUserService = context.read<AppUserService03>();
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('Profile'),
            onTap: () => Navigator.pushNamed(
              context,
              '/profile',
              arguments: AppUserService02().current.sanitarian,
            ),
          ),
          ListTile(
            iconColor: context.colorScheme.error,
            textColor: context.colorScheme.error,
            leading: Icon(Icons.logout_outlined),
            title: Text('Logout'),
            onTap: () => appUserService.logout().then(
              (_) => Navigator.pushNamed(context, '/login'),
            ),
          ),
        ],
      ),
    );
  }
}
