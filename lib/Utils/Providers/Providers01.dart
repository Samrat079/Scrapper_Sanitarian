import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:scrapper/Services/OrderServices/OrderListService04.dart';

import '../../Services/AppUserServices/AppUserService03.dart';
import '../../Services/GeoLocatorService/GeoLocator03.dart';
import '../../Services/MapLauncher/MapLauncher.dart';
import '../../Services/NominatimServices/NominatimServices01.dart';
import '../../Services/OSRMServices/OSRMService01.dart';
import '../../Services/OrderServices/OrderListService03.dart';
import '../../Services/OrderServices/OrderService04.dart';

final List<SingleChildStatelessWidget> providers01 = [
  /// GeoLocation, everyone needs it
  /// try to restructure it to not need init
  ChangeNotifierProvider(create: (context) => GeoLocator03()..init()),

  /// Map launcher, doesn't has any change
  Provider(create: (context) => MapLaunch()),

  /// Nominatim service, doesm't has changes
  Provider(create: (context) => NominatimServices01()),

  /// OSRM service
  Provider(create: (context) => OSRMService01()),

  /// Unable to add address02services as it needs constructor values
  /// not sure how to do that, consider revisiting later

  /// Curr order needs to be init with the whatever order needs
  /// to be listened to
  ChangeNotifierProxyProvider<GeoLocator03, OrderService04>(
    create: (context) => OrderService04(context.read<GeoLocator03>()),
    update: (context, geo, previous) {
      if (previous == null) return OrderService04(geo);
      previous.updateGeo(geo);
      return previous;
    },
  ),

  /// List of orders has geo as dependency
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

  ChangeNotifierProxyProvider<AppUserService03, OrderListService04>(
    create: (context) =>
        OrderListService04(appUser: context.read<AppUserService03>())..init(),
    update: (_, appUser, previous) {
      if (previous == null) {
        return OrderListService04(appUser: appUser)..init();
      }
      previous.updateDependencies(appUser);
      return previous;
    },
  ),
];
