import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as _;
import 'package:provider/provider.dart';
import 'package:scrapper/Services/AppUserServices/AppUserService02.dart';
import 'package:scrapper/Services/OrderServices/OrderService04.dart';
import 'package:scrapper/Utils/Router/RouteGen.dart';
import 'package:scrapper/firebase_options.dart';
import 'package:scrapper/theme/app_theme.dart';

import 'Services/AppUserServices/AppUserService03.dart';
import 'Services/GeoLocatorService/GeoLocator03.dart';
import 'Services/OrderServices/OrderListService03.dart';
import 'Services/OrderServices/OrderService03.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AppUserService02().init();
  // runApp(const MyApp());
  runApp(
    MultiProvider(
      providers: [
        /// 1. Geo (base dependency)
        ChangeNotifierProvider(create: (context) => GeoLocator03()..init()),

        /// 2. OrderService03 (depends on Geo)
        ChangeNotifierProxyProvider<GeoLocator03, OrderService04>(
          create: (context) => OrderService04(context.read<GeoLocator03>()),
          update: (context, geo, previous) {
            if (previous == null) return OrderService04(geo);
            previous.updateGeo(geo);
            return previous;
          },
        ),

        /// 3. Order List Service (depends on Geo + OrderService03)
        ChangeNotifierProxyProvider2<
          GeoLocator03,
          OrderService04,
          OrderListService03
        >(
          create: (context) => OrderListService03(
            context.read<GeoLocator03>(),
            context.read<OrderService04>(),
          ),
          update: (_, geo, orderService, previous) {
            if (previous == null) return OrderListService03(geo, orderService);
            previous.updateDependencies(geo, orderService);
            return previous;
          },
        ),

        /// AppUser03
        ChangeNotifierProxyProvider3<
          GeoLocator03,
          OrderListService03,
          OrderService04,
          AppUserService03
        >(
          create: (context) => AppUserService03(
            geo: context.read<GeoLocator03>(),
            orderList: context.read<OrderListService03>(),
            orderService: context.read<OrderService04>(),
          ),
          update: (context, geo, orderList, orderService, previous) {
            if (previous == null) {
              return AppUserService03(
                geo: geo,
                orderList: orderList,
                orderService: orderService,
              );
            }

            previous.updateDependencies(geo, orderList, orderService);
            return previous;
          },
        ),
      ],
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
