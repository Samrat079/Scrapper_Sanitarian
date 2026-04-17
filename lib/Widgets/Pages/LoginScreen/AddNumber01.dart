import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_intl_phone_field/flutter_intl_phone_field.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:scrapper/Services/AppUserServices/AppUserServices01.dart';

import '../../Custome/CenterColumn/CenterColumn01.dart';

class AddNumber01 extends StatefulWidget {
  final PageController _controller;

  const AddNumber01({super.key, required PageController controller})
    : _controller = controller;

  @override
  State<AddNumber01> createState() => _AddNumber01State();
}

class _AddNumber01State extends State<AddNumber01> {
  final _addNumberKey = GlobalKey<FormBuilderState>();

  void clear() => _addNumberKey.currentState!.reset();

  void submitHandler() async {
    if (_addNumberKey.currentState?.saveAndValidate() ?? false) {
      final number = _addNumberKey.currentState?.fields['Phone']?.value;

      AppUserServices01()
          .sendOtp(number)
          .then(
            (_) => widget._controller.nextPage(
              duration: Duration(seconds: 1),
              curve: Curves.easeInOut,
            ),
          )
          .onError<FirebaseAuthException>(
            (e, stackTrace) => _addNumberKey.currentState?.fields['Phone']
                ?.invalidate(e.message.toString()),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _addNumberKey,
      child: CenterColumn01(
        children: [
          Image.asset('assets/Illustrations/login02.png', height: 256),
          SizedBox(height: 16),
          Text(
            'Verify Phone number',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 20),

          FormBuilderField(
            name: 'Phone',
            builder: (field) {
              return IntlPhoneField(
                onChanged: (phone) => field.didChange(phone.completeNumber),
                initialCountryCode: 'IN',
                decoration: InputDecoration(
                  labelText: 'Phone',
                  hintText: '888-444-6464',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(90),
                  ),
                  errorText: field.errorText,
                  errorMaxLines: 3,
                  errorStyle: TextStyle(fontStyle: FontStyle.italic),
                ),
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
