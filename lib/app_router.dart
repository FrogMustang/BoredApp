import 'package:bored_app/screen/home_screen.dart';
import 'package:go_router/go_router.dart';

enum AppRoute {
  home,
}

class AppRouter {
  static final GoRouter _router = GoRouter(
    debugLogDiagnostics: true,
    routes: <GoRoute>[
      GoRoute(
        name: AppRoute.home.name,
        path: '/',
        builder: (context, state) {
          return const HomeScreen();
        },
      ),
    ],
  );

  static GoRouter get router => _router;
}
