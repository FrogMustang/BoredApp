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
    String? type,
    int? participants,
    double? minPrice,
    double? maxPrice,
    double? minAccessibility,
    double? maxAccessibility,
  }) {
    _activityBloc.add(
      GetFilteredActivities(
        howMany: howMany,
        type: type,
        participants: participants,
        minPrice: minPrice,
        maxPrice: maxPrice,
        minAccessibility: minAccessibility,
        maxAccessibility: maxAccessibility,
      ),
    );
  }

  void resetFilteredActivities() {
    _activityBloc.add(ResetFilteredActivities());
  }

  void selectedActivity({required Activity? activity}) {
    _activityBloc.add(SelectedActivity(activity));
  }
}
