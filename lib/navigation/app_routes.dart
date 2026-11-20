import 'package:flutter/material.dart';

import '../features/authentication/login_screen.dart';
import '../features/authentication/signup_screen.dart';

class AppRoutes {
  static const String login = '/';
  static const String signup = '/signup';
  static const String dashboard = '/dashboard';
  static const String inventory = '/inventory';
  static const String consumeStock = '/consume-stock';

  static final Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    signup: (context) => const SignUpScreen(),
  };
}
