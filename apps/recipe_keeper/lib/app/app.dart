import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme.dart';

/// Main app widget
/// 
/// This is the root widget of the application.
/// Wrapped with ProviderScope for Riverpod state management.
class RecipeKeeperApp extends StatelessWidget {
  const RecipeKeeperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Recipe Keeper',
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: ThemeMode.light,
        initialRoute: AppRouter.initialRoute,
        // TODO: Routes will be migrated from lib/src/app.dart
        // For now, routes are still defined in the old location
        // routes: _buildRoutes(),
        // onGenerateRoute: _onGenerateRoute,
      ),
    );
  }

  // TODO: Migrate routes from lib/src/app.dart
  // static Map<String, WidgetBuilder> _buildRoutes() {
  //   return {
  //     AppRouter.home: (context) => const HomeScreen(),
  //     // ... other routes
  //   };
  // }
}

