import 'package:bored_app/application.dart';
import 'package:bored_app/bloc/activity/activities_bloc.dart';
import 'package:bored_app/constants.dart';
import 'package:bored_app/screen/widgets/activity_widget.dart';
import 'package:bored_app/screen/widgets/error_screen.dart';
import 'package:bored_app/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RandomActivitiesScreen extends StatefulWidget {
  const RandomActivitiesScreen({super.key});

  @override
  State<RandomActivitiesScreen> createState() => _RandomActivitiesScreenState();
}

class _RandomActivitiesScreenState extends State<RandomActivitiesScreen> {
  final ActivitiesBloc _activitiesBloc = getIt<ActivitiesBloc>();

  /// Used to add events to the [ActivitiesBloc]
  final ActivitiesController activitiesController = ActivitiesController(
    activityBloc: getIt<ActivitiesBloc>(),
  );

  /// Used to fetch more activities when almost at the end of the list
  final ScrollController randomScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    activitiesController.getRandomActivities(
      howMany: Constants.howManyRandomActivities,
    );

    randomScrollController.addListener(() {
      if (randomScrollController.position.extentAfter < 500 &&
          _activitiesBloc.state.randomStatus != ActivitiesStatus.loading) {
        activitiesController.getRandomActivities(
          howMany: Constants.howManyRandomActivities,
        );
      }
    });
  }

  @override
  void dispose() {
    randomScrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivitiesBloc, ActivitiesState>(
      bloc: _activitiesBloc,
      builder: (context, state) {
        if ((state.randomStatus == ActivitiesStatus.fetched ||
                state.randomStatus == ActivitiesStatus.loading) &&
            state.randomActivities.isNotEmpty) {
          return ScrollConfiguration(
            behavior: NoMoreGlow(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ListView(
                key: const Key('randomList'),
                controller: randomScrollController,
                children: [
                  for (int i = 1; i <= state.randomActivities.length; i++)
                    ActivityWidget(
                      activity: state.randomActivities[i - 1],
                      index: i,
                      status: state.randomStatus,
                    ),
                  if (state.randomStatus == ActivitiesStatus.loading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: CupertinoActivityIndicator(),
                    ),
                ],
              ),
            ),
          );
        }

        if (state.error != null) {
          return ErrorScreen(
            retryCallback: () {
              activitiesController.getRandomActivities(
                howMany: Constants.howManyRandomActivities,
              );
            },
          );
        }

        return const Center(
          child: CupertinoActivityIndicator(),
        );
      },
    );
  }
}
