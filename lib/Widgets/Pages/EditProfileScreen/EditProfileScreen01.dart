import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrapper/Services/AppUserServices/AppUserService03.dart';
import 'package:scrapper/Widgets/Custome/CenterColumn/CenterColumn04.dart';
import 'package:scrapper/Widgets/Custome/Forms/EditProfileForm01.dart';
import 'package:scrapper/theme/theme_extensions.dart';

import '../../../Services/AppUserServices/AppUserService02.dart';

class EditProfileScreen01 extends StatelessWidget {
  const EditProfileScreen01({super.key});

  @override
  Widget build(BuildContext context) {
    // final appUserService = AppUserService02();
    final appUserService = context.read<AppUserService03>();
    return Scaffold(
      appBar: AppBar(),
      body: CenterColumn04(
        centerVertically: true,
        children: [
          Text("Edit profile"),
          context.gapMD,
          EditProfileForm01(
            appUser: appUserService.current,
            onCancel: () => Navigator.pop(context),
            onSubmit: (data) => appUserService
                .updateAppUser(data['displayName'])
                .then((_) => Navigator.pop(context)),
          ),
        ],
      ),
    );
  }
}
