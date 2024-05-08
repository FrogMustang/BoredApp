import 'package:bored_app/application.dart';
import 'package:bored_app/bloc/activity/activities_bloc.dart';
import 'package:bored_app/constants.dart';
import 'package:bored_app/screen/widgets/activities_not_found.dart';
import 'package:bored_app/screen/widgets/activity_widget.dart';
import 'package:bored_app/screen/widgets/error_screen.dart';
import 'package:bored_app/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FilteredActivitiesScreen extends StatefulWidget {
  const FilteredActivitiesScreen({super.key});

  @override
  State<FilteredActivitiesScreen> createState() =>
      _FilteredActivitiesScreenState();
}

class _FilteredActivitiesScreenState extends State<FilteredActivitiesScreen> {
  final ActivitiesBloc _activitiesBloc = getIt<ActivitiesBloc>();

  /// Used to add events to the [ActivitiesBloc]
  final ActivitiesController activitiesController = ActivitiesController(
    activityBloc: getIt<ActivitiesBloc>(),
  );

  final ScrollController filteredScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // reset the filtered activities
    activitiesController.resetFilteredActivities();

    // reset the filters
    activitiesController.resetFilters();

    /// and get new ones
    activitiesController.getFilteredActivities(
      howMany: Constants.howManyFilteredActivities,
    );

    filteredScrollController.addListener(() {
      if (filteredScrollController.position.extentAfter < 500 &&
          _activitiesBloc.state.filteredStatus != ActivitiesStatus.loading) {
        activitiesController.getFilteredActivities(
          howMany: Constants.howManyFilteredActivities,
          filters: _activitiesBloc.state.filters,
        );
      }
    });
  }

  @override
  void dispose() {
    filteredScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivitiesBloc, ActivitiesState>(
      bloc: _activitiesBloc,
      builder: (context, state) {
        if ((state.filteredStatus == ActivitiesStatus.fetched ||
                state.filteredStatus == ActivitiesStatus.loading) &&
            state.filteredActivities.isNotEmpty) {
          return ScrollConfiguration(
            behavior: NoMoreGlow(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ListView(
                key: const Key('filteredList'),
                controller: filteredScrollController,
                children: [
                  for (int i = 1; i <= state.filteredActivities.length; i++)
                    ActivityWidget(
                      activity: state.filteredActivities[i - 1],
                      index: i,
                      status: state.filteredStatus,
                    ),
                  if (state.filteredStatus == ActivitiesStatus.loading)
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
          if (state.error.message.contains('No activity found')) {
            return const ActivitiesNotFound();
          } else {
            return const ErrorScreen();
          }
        }

        return const Center(
          child: CupertinoActivityIndicator(),
        );
      },
    );
  }
}
