import 'package:flutter/material.dart';

// class NavigationService {
//   final GlobalKey<NavigatorState> navigatorKey =
//       GlobalKey<NavigatorState>(debugLabel: 'navigate_key');

//   NavigatorState get navigator => navigatorKey.currentState!;
// }
class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  NavigatorState get navigator => navigatorKey.currentState!;
}
