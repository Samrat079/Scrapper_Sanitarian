import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:scrapper/Services/AppUserServices/AppUserService03.dart';
import 'package:scrapper/theme/theme_extensions.dart';

import '../../../Custome/CenterColumn/CenterColumn04.dart';

class AddOtp01 extends StatefulWidget {
  final PageController controller;

  const AddOtp01({super.key, required this.controller});

  @override
  State<AddOtp01> createState() => _AddOtp01State();
}

class _AddOtp01State extends State<AddOtp01> {
  late AppUserService03 appUserService;

  final PinInputController otpController = PinInputController();

  bool isLoading = false;
  String? errorText;

  @override
  void initState() {
    super.initState();
    appUserService = Provider.of<AppUserService03>(context, listen: false);
  }

  void submitOtp(String pin) async {
    setState(() => errorText = null);

    /// 🔥 HARD VALIDATION (blocks <6 digits)
    if (pin.length != 6) {
      setError("OTP must be 6 digits");
      return;
    }

    final otp = int.tryParse(pin);
    if (otp == null) {
      setError("Invalid OTP");
      return;
    }

    setState(() => isLoading = true);

    try {
      await appUserService.verifyOtp(pin);

      widget.controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      setError("Verification failed");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void setError(String message) {
    otpController.triggerError(); // 🔥 shake animation
    setState(() => errorText = message);
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CenterColumn04(
      centerVertically: true,
      padding: context.paddingXL,
      children: [
        Image.asset('assets/Illustrations/otp01.png', height: 256),
        context.gapMD,

        Text(
          'Please enter OTP',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        context.gapXL,

        CenterColumn04(
          centerHorizontally: true,
          children: [
            MaterialPinField(
              length: 6,
              pinController: otpController,
              onCompleted: submitOtp,
              theme: MaterialPinTheme(cellSize: const Size(40, 46)),
            ),
            context.gapSM,

            if (errorText != null)
              Text(
                errorText!,
                style: TextStyle(
                  color: context.colorScheme.error,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),

        if (isLoading) const LinearProgressIndicator(),
        context.gapMD,

        ElevatedButton(
          onPressed: isLoading ? null : () => submitOtp(otpController.text),
          child: const Text("Submit"),
        ),

        context.gapMD,

        ElevatedButton(
          onPressed: () => otpController.clear(),
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colorScheme.surfaceContainerHigh,
            foregroundColor: context.colorScheme.onSurface,
          ),
          child: const Text("Clear"),
        ),
      ],
    );
  }
}
