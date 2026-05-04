import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrapper/Utils/Router/RouteGen.dart';
import 'package:scrapper/firebase_options.dart';
import 'package:scrapper/theme/app_theme.dart';

import 'package:scrapper/Utils/Providers/Providers01.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: providers01,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      /// Have to send context to it or else it cant get
      /// the AppUserService03
      onGenerateRoute: (settings) => RouteGen.generateRoute(context, settings),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
    );
  }
}
