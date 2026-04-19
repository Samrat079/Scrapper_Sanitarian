import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_intl_phone_field/flutter_intl_phone_field.dart';
import 'package:scrapper/Services/AppUserServices/AppUserService02.dart';
import 'package:scrapper/theme/theme_extensions.dart';

import '../../../Custome/CenterColumn/CenterColumn04.dart';

class AddNumber01 extends StatefulWidget {
  final PageController _controller;

  const AddNumber01({super.key, required PageController controller})
    : _controller = controller;

  @override
  State<AddNumber01> createState() => _AddNumber01State();
}

class _AddNumber01State extends State<AddNumber01> {
  final _addNumberKey = GlobalKey<FormBuilderState>();
  bool isLoading = false;

  void clear() => _addNumberKey.currentState!.reset();

  void submitHandler() async {
    setState(() => isLoading = true);
    if (_addNumberKey.currentState?.saveAndValidate() ?? false) {
      final number = _addNumberKey.currentState?.fields['Phone']?.value;

      AppUserService02()
          .sendOtp(number)
          .then(
            (_) => widget._controller.nextPage(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            ),
          )
          .onError<FirebaseAuthException>((e, stackTrace) {
            _addNumberKey.currentState?.fields['Phone']?.invalidate(
              e.message.toString(),
            );
            setState(() => isLoading = false);
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _addNumberKey,
      child: CenterColumn04(
        centerVertically: true,
        padding: context.paddingXL,
        children: [
          Image.asset('assets/Illustrations/login02.png', height: 256),
          context.gapMD,
          Text(
            'Verify Phone number',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          context.gapXL,

          FormBuilderField(
            name: 'Phone',
            builder: (field) {
              return IntlPhoneField(
                onChanged: (phone) => field.didChange(phone.completeNumber),
                initialCountryCode: 'IN',
                decoration: InputDecoration(
                  filled: true,
                  fillColor: context.colorScheme.surfaceContainer,
                  labelText: 'Phone',
                  hintText: '888-444-6464',
                  errorText: field.errorText,
                  errorMaxLines: 2,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: context.radiusMD,
                    borderSide: BorderSide(color: context.colorScheme.outline),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: context.radiusMD,
                    borderSide: BorderSide(
                      color: context.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
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
