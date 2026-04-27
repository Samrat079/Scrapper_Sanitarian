import 'package:flutter/cupertino.dart';
import 'package:scrapper/Services/AppUserServices/AppUserService02.dart';
import 'package:scrapper/Widgets/Custome/CenterColumn/CenterColumn04.dart';
import 'package:scrapper/Widgets/Custome/Forms/EditProfileForm01.dart';
import 'package:scrapper/theme/theme_extensions.dart';

class EditProfileView01 extends StatelessWidget {
  final PageController _controller;

  const EditProfileView01({super.key, required PageController controller})
    : _controller = controller;

  /// The edit profile form needs to be dynamic
  /// so this wrapper exists to wrap that and
  /// do the submit function

  @override
  Widget build(BuildContext context) => CenterColumn04(
    centerVertically: true,
    padding: context.paddingLG,
    children: [
      Image.asset('assets/Illustrations/otp01.png', height: 256),
      context.gapMD,
      Text(
        'Add username',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      context.gapMD,
      EditProfileForm01(
        onSubmit: (data) => AppUserService02()
            .updateAppUser(data['displayName'])
            .then((_) => Navigator.pushReplacementNamed(context, '/profile')),
        onCancel: () => Navigator.pop(context),
      ),
    ],
  );
}
