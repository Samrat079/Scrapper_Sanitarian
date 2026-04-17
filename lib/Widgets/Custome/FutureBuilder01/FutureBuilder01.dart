import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FutureBuilder01<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(BuildContext, T) child;

  const FutureBuilder01({super.key, required this.future, required this.child});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Text('Something went wrong'));
        if (snapshot.hasData) return child(context, snapshot.data as T);
        return Center(child: Text('No data'));
      },
    );
  }
}
