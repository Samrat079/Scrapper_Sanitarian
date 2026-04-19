
import 'package:flutter/cupertino.dart';

class KmText01 extends StatelessWidget {
  final double meters;

  const KmText01({super.key, required this.meters});

  @override
  Widget build(BuildContext context) {
    final distance = (meters / 1000).toStringAsFixed(2);
    return Text('Km $distance');
  }
}
