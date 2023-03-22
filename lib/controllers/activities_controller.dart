part of 'package:bored_app/bloc/activity/activities_bloc.dart';

class ActivitiesController {
  final ActivitiesBloc _activityBloc;

  ActivitiesController({
    required ActivitiesBloc activityBloc,
  }) : _activityBloc = activityBloc;

  /// Send Bloc event to fetch [howMany] random items from API
  void getRandomActivities({required int howMany}) async {
    _activityBloc.add(_GetRandomActivities(howMany));
  }
}
