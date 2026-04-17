import 'package:flutter/material.dart';
import 'package:scrapper/Models/Address/Address02.dart';
import 'package:scrapper/Models/Customer/Customer01.dart';
import 'package:scrapper/Services/AppUserServices/AppUserServices01.dart';
import 'package:scrapper/Widgets/Pages/LocationForm/LocationForm01.dart';

import '../../Widgets/Pages/AddressesScreen/AddressesScreen01.dart';
import '../../Widgets/Pages/ErrorScreen/ErrorScreen01.dart';
import '../../Widgets/Pages/HomeScreen/HomeScreen01.dart';
import '../../Widgets/Pages/LoginScreen/LoginScreen01.dart';
import '../../Widgets/Pages/ProfileScreen/ProfileScreen01.dart';

class RouteGen {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    final name = settings.name;
    final isLoggedIn = AppUserServices01().isLoggedIn;

    /// reduces boiler plate
    Route<dynamic> router<T>(Widget page) =>
        MaterialPageRoute<T>(builder: (_) => page);

    /// Unguarded routes
    switch (name) {
      case '/':
        return router(HomeScreen01());
      case '/login':
        return router(LoginScreen01());
      case '/error':
        return router(ErrorScreen01());
      case '/location01':
        return router<Address02>(LocationForm01());
    }

    /// Protected route
    if (!isLoggedIn) return router(LoginScreen01());

    switch (name) {
      // case '/location01':
      //   return MaterialPageRoute(builder: (_) => LocationForm01());
      case '/profile':
        return router(ProfileScreen01());
      case '/addresses':
        return router(AddressesScreen01(customer: args as Customer01));
    }

    return router(ErrorScreen01());
  }
}
