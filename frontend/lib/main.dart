import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:revolutionary_commerce/core/theme/app_theme.dart';
import 'package:revolutionary_commerce/core/router/app_router.dart';
import 'package:revolutionary_commerce/features/auth/application/auth_notifier.dart';
import 'package:revolutionary_commerce/shared/widgets/crazy_loading_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase initialization removed for Guest/Mock mode
  runApp(const ProviderScope(child: RevolutionaryApp()));
}

class RevolutionaryApp extends StatefulWidget {
  const RevolutionaryApp({super.key});

  @override
  State<RevolutionaryApp> createState() => _RevolutionaryAppState();
}

class _RevolutionaryAppState extends State<RevolutionaryApp> {
  bool _showLoading = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Revolutionary Commerce',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: _showLoading
          ? CrazyLoadingScreen(
              duration: const Duration(seconds: 4),
              onComplete: () {
                setState(() {
                  _showLoading = false;
                });
              },
            )
          : const _MainApp(),
    );
  }
}

class _MainApp extends ConsumerWidget {
  const _MainApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Revolutionary Commerce',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
