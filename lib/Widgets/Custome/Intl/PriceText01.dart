import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class PriceText01 extends StatelessWidget {
  final double price;

  const PriceText01({super.key, required this.price});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );

    return Text(formatter.format(price));
  }
}
