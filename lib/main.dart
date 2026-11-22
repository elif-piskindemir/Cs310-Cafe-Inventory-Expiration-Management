
import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'navigation/app_routes.dart';

void main() {
  runApp(const CafeStockApp());
}

class CafeStockApp extends StatelessWidget {
  const CafeStockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CafeStock',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,

      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,
    );
  }
}
