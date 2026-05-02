import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:scrapper/Widgets/Custome/CenterColumn/CenterColumn04.dart';
import 'package:scrapper/theme/theme_extensions.dart';

import '../../../../Models/Orders/Order01.dart';

class OrderOtpSheet01 extends StatefulWidget {
  /// Params
  final Order01 order;
  final ScrollController controller;
  final VoidCallback onGoBack;
  final Function(int) onSubmit;

  const OrderOtpSheet01({
    super.key,
    required this.order,
    required this.controller,
    required this.onGoBack,
    required this.onSubmit,
  });

  @override
  State<OrderOtpSheet01> createState() => _OrderOtpSheet01State();
}

class _OrderOtpSheet01State extends State<OrderOtpSheet01> {
  /// This is the form key
  final otpKey = GlobalKey<FormBuilderState>();

  /// Loading State
  bool isLoading = false;

  /// Submit handler
  void submitHandler() async {
    setState(() => isLoading = true);

    try {
      if (otpKey.currentState?.saveAndValidate() ?? false) {
        final formData = otpKey.currentState!.value;
        final otp = int.parse(formData['Otp']);

        if (otp != widget.order.otp) {
          otpKey.currentState?.fields['Otp']?.invalidate(
            "The otp doesn't match, please try again",
          );
          return;
        }

        await widget.onSubmit(otp);
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    /// Better to wrap the ui with the form
    return SafeArea(
      child: FormBuilder(
        key: otpKey,
        child: CenterColumn04(
          centerVertically: true,
          scrollController: widget.controller,
          children: [
            Icon(Icons.lock_outline_rounded, size: 82),
            context.gapMD,

            Text(
              "Verify otp",
              textAlign: TextAlign.center,
              style: context.textTheme.headlineLarge,
            ),
            context.gapLG,

            /// Pin filed
            FormBuilderField(
              name: 'Otp',
              validator: FormBuilderValidators.minLength(6),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              builder: (field) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MaterialPinField(
                      length: 6,
                      errorText: field.errorText,
                      onChanged: (otp) => field.didChange(otp),
                      theme: MaterialPinTheme(cellSize: Size(40, 46)),
                    ),
                    context.gapSM,

                    /// This is the error text
                    if (field.hasError)
                      Text(
                        field.errorText ?? '',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: context.colorScheme.error,
                        ),
                      ),
                    context.gapMD,

                    /// hint
                    Text(
                      "Please ask the customer for the otp to complete this order",
                      style: context.textTheme.labelSmall,
                    ),
                    context.gapMD,
                  ],
                );
              },
            ),

            /// Loading state
            if (isLoading)
              Column(children: [LinearProgressIndicator(), context.gapMD]),

            ElevatedButton.icon(
              onPressed: isLoading ? null : submitHandler,
              label: Text("Submit"),
              icon: Icon(Icons.check),
            ),
            context.gapMD,

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colorScheme.surfaceContainerHigh,
                foregroundColor: context.colorScheme.onSurface,
              ),
              onPressed: widget.onGoBack,
              label: Text("Go back"),
              icon: Icon(Icons.exit_to_app),
            ),
          ],
        ),
      ),
    );
  }
}
