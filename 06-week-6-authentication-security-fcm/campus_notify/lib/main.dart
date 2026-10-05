import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/announcement_page.dart';
import 'providers/auth_provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final GoRouter router;

  @override
  void initState() {
    super.initState();

    router = GoRouter(
      redirect: (context, state) {
        final loggedIn =
            ref.read(authStateProvider).value ?? false;

        final goingLogin = state.matchedLocation == '/login';

        if (!loggedIn && !goingLogin) return '/login';

        if (loggedIn && goingLogin) return '/';

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (_, _) => const LoginPage(),
        ),
        GoRoute(
          path: '/',
          builder: (_, _) => const HomePage(),
        ),
        GoRoute(
          path: '/pengumuman/:id',
          builder: (_, state) {
            return AnnouncementPage(
              id: state.pathParameters['id'] ?? '',
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authStateProvider, (previous, next) {
      router.refresh();
    });

    return MaterialApp.router(
      title: 'Campus Notify',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
      ),
      routerConfig: router,
    );
  }
}