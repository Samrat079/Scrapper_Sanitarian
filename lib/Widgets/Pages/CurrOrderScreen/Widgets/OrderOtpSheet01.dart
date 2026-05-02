import 'package:flutter/material.dart';
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
  final controller = PinInputController();

  String? errorText;
  bool isLoading = false;

  void handleOtp(String pin) async {
    /// Reset previous error
    setState(() => errorText = null);

    if (pin.length < 6) {
      setError("OTP must be 6 digits");
      return;
    }

    final otp = int.tryParse(pin);
    if (otp == null) {
      setError("Invalid OTP");
      return;
    }

    if (otp != widget.order.otp) {
      setError("OTP doesn't match");
      return;
    }

    setState(() => isLoading = true);

    try {
      await widget.onSubmit(otp);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void setError(String message) {
    controller.triggerError(); // 🔥 shake + red
    setState(() => errorText = message);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CenterColumn04(
        centerVertically: true,
        centerHorizontally: true,
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

          /// OTP field
          MaterialPinField(
            length: 6,
            pinController: controller,
            onCompleted: handleOtp,
            theme: MaterialPinTheme(cellSize: Size(40, 46)),
          ),

          context.gapSM,

          /// Error text
          if (errorText != null)
            Text(
              errorText!,
              style: TextStyle(
                color: context.colorScheme.error,
                fontStyle: FontStyle.italic,
              ),
            ),

          context.gapMD,

          Text(
            "Please ask the customer for the otp to complete this order",
            style: context.textTheme.labelSmall,
          ),
          context.gapSM,

          if (isLoading)
            Column(children: [LinearProgressIndicator(), context.gapMD]),

          CenterColumn04(
            children: [
              ElevatedButton.icon(
                onPressed: isLoading ? null : () => handleOtp(controller.text),
                label: Text("Submit"),
                icon: Icon(Icons.check),
              ),
              context.gapMD,

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  foregroundColor: context.colorScheme.onSurface,
                  backgroundColor: context.colorScheme.surfaceContainerHigh,
                ),
                onPressed: widget.onGoBack,
                label: Text("Go back"),
                icon: Icon(Icons.exit_to_app),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
