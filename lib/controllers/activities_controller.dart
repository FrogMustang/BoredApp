part of 'package:bored_app/bloc/activity/activities_bloc.dart';

class ActivitiesController {
  final ActivitiesBloc _activityBloc;

  ActivitiesController({
    required ActivitiesBloc activityBloc,
  }) : _activityBloc = activityBloc;

  /// Add Bloc event to fetch [howMany] random items from API
  void getRandomActivities({required int howMany}) {
    _activityBloc.add(GetRandomActivities(howMany));
  }

  /// Add Bloc event to fetch filtered activities from API
  void getFilteredActivities({
    required int howMany,
    ActivityFilters? filters,
  }) {
    _activityBloc.add(
      GetFilteredActivities(
        howMany: howMany,
        filters: filters,
      ),
    );
  }

  void updateFilters(ActivityFilters newFilters) {
    _activityBloc.add(
      UpdateActivityFilters(
        filters: newFilters,
      ),
    );
  }

  void resetFilteredActivities() {
    _activityBloc.add(ResetFilteredActivities());
  }

  void resetFilters() {
    _activityBloc.add(ResetFilters());
  }

  void selectedActivity({required Activity? activity}) {
    _activityBloc.add(SelectedActivity(activity));
  }
}
