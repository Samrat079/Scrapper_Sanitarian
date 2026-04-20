import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:scrapper/Services/AppUserServices/AppUserService02.dart';
import 'package:scrapper/theme/theme_extensions.dart';

import '../../../Custome/CenterColumn/CenterColumn04.dart';

class AddOtp01 extends StatefulWidget {
  final PageController _controller;

  const AddOtp01({super.key, required PageController controller})
    : _controller = controller;

  @override
  State<AddOtp01> createState() => _AddOtp01State();
}

class _AddOtp01State extends State<AddOtp01> {
  final _otpController = GlobalKey<FormBuilderState>();

  void clear() => _otpController.currentState!.reset();
  bool isLoading = false;

  void submitHandler() async {
    setState(() => isLoading = true);
    if (_otpController.currentState?.saveAndValidate() ?? false) {
      final otp = _otpController.currentState?.fields['Otp']?.value;
      AppUserService02()
          .verifyOtp(otp)
          .then(
            (_) => widget._controller.nextPage(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            ),
          )
          .onError<FirebaseAuthException>((e, stackTrace) {
            _otpController.currentState?.fields['Otp']?.invalidate(
              e.message.toString(),
            );
            setState(() => isLoading = false);
            return;
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _otpController,
      child: CenterColumn04(
        centerVertically: true,
        padding: context.paddingXL,
        children: [
          Image.asset('assets/Illustrations/otp01.png', height: 256),
          context.gapMD,
          Text(
            'Please add otp',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          context.gapXL,

          FormBuilderField(
            name: 'Otp',
            builder: (field) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MaterialPinField(
                    key: ValueKey(field.errorText),
                    length: 6,
                    onChanged: (otp) => field.didChange(otp),
                    theme: MaterialPinTheme(cellSize: Size(40, 46)),
                  ),

                  context.gapSM,
                  Text(
                    field.errorText ?? '',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              );
            },
          ),

          context.gapMD,

          ElevatedButton(
            onPressed: isLoading ? null : submitHandler,
            child: Text('Submit'),
          ),
          context.gapMD,
          ElevatedButton(
            onPressed: clear,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colorScheme.surfaceContainerHigh,
              foregroundColor: context.colorScheme.onSurface,
            ),
            child: Text('Clear'),
          ),
        ],
      ),
    );
  }
}
