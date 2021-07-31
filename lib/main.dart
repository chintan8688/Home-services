import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:home_services/src/app.dart';
import 'package:home_services/src/utills/push_manager.dart';
import 'package:timezone/data/latest.dart' as tz;

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();
RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  PushNotificationsManager().init();
  tz.initializeTimeZones();
  runApp(
    HomeServices(),
  );
}
