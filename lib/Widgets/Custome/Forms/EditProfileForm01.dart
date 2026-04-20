import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:scrapper/Models/AppUser/AppUser02.dart';
import 'package:scrapper/Services/AppUserServices/AppUserService02.dart';
import 'package:scrapper/Widgets/Custome/CenterColumn/CenterColumn04.dart';
import 'package:scrapper/theme/theme_extensions.dart';

class EditProfileForm01 extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const EditProfileForm01({super.key, required this.onSubmit});

  @override
  State<EditProfileForm01> createState() => _EditProfileForm01State();
}

class _EditProfileForm01State extends State<EditProfileForm01> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool isLoading = false;
  final AppUser02 currUser = AppUserService02().current;

  void clear() => _formKey.currentState!.reset();

  void submitHandler() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() => isLoading = true);
      final currState = _formKey.currentState!.value;
      await widget.onSubmit(currState);

      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          /// Photo URL
          // FormBuilderTextField(
          //   name: 'photoUrl',
          //   validator: FormBuilderValidators.url(requireProtocol: true),
          //   autovalidateMode: AutovalidateMode.onUserInteraction,
          //   decoration: InputDecoration(
          //     prefixIcon: Icon(
          //       Icons.image_outlined,
          //       color: context.colorScheme.secondary,
          //     ),
          //     labelText: 'Photo URL',
          //     filled: true,
          //     fillColor: context.colorScheme.surfaceContainer,
          //     enabledBorder: OutlineInputBorder(
          //       borderRadius: context.radiusMD,
          //       borderSide: BorderSide(color: context.colorScheme.outline),
          //     ),
          //     focusedBorder: OutlineInputBorder(
          //       borderRadius: context.radiusMD,
          //       borderSide: BorderSide(
          //         color: context.colorScheme.outline,
          //       ),
          //     ),
          //   ),
          // ),

          // context.gapMD,

          /// Phone Number
          // FormBuilderTextField(
          //   name: 'phoneNumber',
          //   validator: FormBuilderValidators.phoneNumber(),
          //   keyboardType: TextInputType.phone,
          //   autovalidateMode: AutovalidateMode.onUserInteraction,
          //   decoration: InputDecoration(
          //     prefixIcon: Icon(
          //       Icons.phone_outlined,
          //       color: context.colorScheme.secondary,
          //     ),
          //     labelText: 'Phone Number',
          //     filled: true,
          //     fillColor: context.colorScheme.surfaceContainer,
          //   ),
          // ),
          // context.gapMD,

          // context.gapMD,

          /// Email
          // FormBuilderTextField(
          //   name: 'email',
          //   validator: FormBuilderValidators.email(checkNullOrEmpty: false),
          //   autovalidateMode: AutovalidateMode.onUserInteraction,
          //   decoration: InputDecoration(
          //     prefixIcon: Icon(
          //       Icons.email_outlined,
          //       color: context.colorScheme.secondary,
          //     ),
          //     labelText: 'Email (optional)',
          //     filled: true,
          //     fillColor: context.colorScheme.surfaceContainer,
          //     enabledBorder: OutlineInputBorder(
          //       borderRadius: context.radiusMD,
          //       borderSide: BorderSide(color: context.colorScheme.outline),
          //     ),
          //     focusedBorder: OutlineInputBorder(
          //       borderRadius: context.radiusMD,
          //       borderSide: BorderSide(color: context.colorScheme.outline),
          //     ),
          //   ),
          // ),

          /// Display Name
          FormBuilderTextField(
            name: 'displayName',
            validator: FormBuilderValidators.username(allowSpace: true),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            initialValue: currUser.sanitarian?.displayName,
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.person_outline,
                color: context.colorScheme.primary,
              ),
              labelText: 'Full Name',
              filled: true,
              fillColor: context.colorScheme.surfaceContainer,
              enabledBorder: OutlineInputBorder(
                borderRadius: context.radiusMD,
                borderSide: BorderSide(color: context.colorScheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: context.radiusMD,
                borderSide: BorderSide(color: context.colorScheme.outline),
              ),
            ),
          ),

          context.gapLG,

          /// Submit
          ElevatedButton(
            onPressed: isLoading ? null : submitHandler,
            child: const Text('Save Changes'),
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
