import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scrapper/Widgets/Custome/CenterColumn/CenterColumn04.dart';
import 'package:scrapper/Widgets/Custome/Forms/EditProfileForm01.dart';
import 'package:scrapper/theme/theme_extensions.dart';

import '../../../Services/AppUserServices/AppUserService02.dart';

class EditProfileScreen01 extends StatelessWidget {
  const EditProfileScreen01({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: CenterColumn04(
      centerVertically: true,
      children: [
        Text("Edit profile"),
        context.gapMD,
        EditProfileForm01(
          onSubmit: (data) => AppUserService02()
              .updateAppUser(data['displayName'])
              .then((_) => Navigator.pop(context)),
          onCancel: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}
