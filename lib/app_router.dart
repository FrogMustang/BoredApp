import 'package:bored_app/application.dart';
import 'package:bored_app/bloc/activity/activities_bloc.dart';
import 'package:bored_app/screen/activity_details_screen.dart';
import 'package:bored_app/screen/home_screen.dart';
import 'package:go_router/go_router.dart';

enum AppRoute {
  home,
  detailsView,
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
        routes: [
          GoRoute(
            name: AppRoute.detailsView.name,
            path: 'details_view',
            builder: (context, state) {
              return const ActivityDetailsScreen();
            },
          ),
        ],
      ),
    ],
  );

  static GoRouter get router => _router;
}
