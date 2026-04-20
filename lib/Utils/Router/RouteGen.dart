import 'package:flutter/material.dart';
import 'package:scrapper/Services/AppUserServices/AppUserService02.dart';
import 'package:scrapper/Widgets/Pages/EditProfileScreen/EditProfileScreen01.dart';
import 'package:scrapper/Widgets/Pages/HomeScreen/HomeScreen01.dart';
import 'package:scrapper/Widgets/Pages/OrdersScreen/OrdersScreen01.dart';

import '../../Widgets/Pages/ErrorScreen/ErrorScreen01.dart';
import '../../Widgets/Pages/HomeScreen/OnDutyScreen/OnDutyScreen01.dart';
import '../../Widgets/Pages/LoginScreen/LoginScreen01.dart';
import '../../Widgets/Pages/ProfileScreen/ProfileScreen01.dart';

class RouteGen {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    final name = settings.name;
    final isLoggedIn = AppUserService02().isLoggedIn;

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
    }

    if (!isLoggedIn) return router(LoginScreen01());

    /// Protected route

    switch (name) {
      case '/profile':
        return router(ProfileScreen01());
      case '/edit_profile':
        return router(EditProfileScreen01());
      case '/orders':
        return router(OrdersScreen01());
    }

    return router(ErrorScreen01());
  }
}
