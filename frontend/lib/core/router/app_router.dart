import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/application/auth_notifier.dart';
import '../../features/home/home_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/shop/presentation/product_listing_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // If auth is loading, do nothing (wait)
      if (authState.isLoading) return null;

      final isLoggedIn = authState.value == true;
      final isLoggingIn = state.uri.path == '/login';

      debugPrint('Redirect Check: loggedIn=$isLoggedIn, path=${state.uri.path}');

      if (!isLoggedIn) {
        return isLoggingIn ? null : '/login';
      }

      if (isLoggingIn) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/shop',
        builder: (context, state) => const ProductListingScreen(),
      ),
    ],
  );
});
