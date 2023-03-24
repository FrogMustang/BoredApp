import 'dart:async';

import 'package:bored_app/app_router.dart';
import 'package:bored_app/bloc/activity/activities_bloc.dart';
import 'package:bored_app/repository/activity_repository.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.instance;

void startApplication() async {
  runZonedGuarded(
    () {
      // instantiate Blocs, Firebase auth etc.
      final activityRepo = ActivitiesRepository();

      final ActivitiesBloc activitiesBloc = ActivitiesBloc(
        activityRepo: activityRepo,
      );

      runApp(BoredAppLauncher(
        activitiesBloc: activitiesBloc,
      ));
    },
    (error, stackTrace) {
      // register errors in crashlytics
    },
  );
}

class BoredAppLauncher extends StatefulWidget {
  final ActivitiesBloc activitiesBloc;

  const BoredAppLauncher({
    Key? key,
    required this.activitiesBloc,
  }) : super(key: key);

  @override
  State<BoredAppLauncher> createState() => _BoredAppLauncherState();
}

class _BoredAppLauncherState extends State<BoredAppLauncher> {
  @override
  void initState() {
    super.initState();
    getIt.reset(dispose: false);
    getIt.registerSingleton(widget.activitiesBloc);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRouter.router,
      builder: (context, child) {
        return SizedBox(
          height: MediaQuery.of(context).size.height,
          child: child,
        );
      },
    );
  }
}
