import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:scrapper/Services/AppUserServices/AppUserServices01.dart';

import '../../Custome/CenterColumn/CenterColumn01.dart';

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

  void submitHandler() async {
    if (_otpController.currentState?.saveAndValidate() ?? false) {
      final otp = _otpController.currentState?.fields['Otp']?.value;
      AppUserServices01()
          .verifyOtp(otp)
          .then(
            (e) => Navigator.pushReplacementNamed(
              context,
              '/profile',
              arguments: e.customer01,
            ),
          )
          .onError<FirebaseAuthException>(
            (e, stackTrace) => _otpController.currentState?.fields['Otp']
                ?.invalidate(e.message.toString()),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _otpController,
      child: CenterColumn01(
        children: [
          Image.asset('assets/Illustrations/otp01.png', height: 256),
          SizedBox(height: 16),

          Text(
            'Please add otp',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 20),

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

                  const SizedBox(height: 2),
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

          SizedBox(height: 16),

          ElevatedButton(
            onPressed: submitHandler,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: Text('Submit'),
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: clear,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHigh,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
            ),
            child: Text('Clear'),
          ),
        ],
      ),
    );
  }
}
