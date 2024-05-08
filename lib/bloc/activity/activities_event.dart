part of 'activities_bloc.dart';

abstract class ActivitiesEvent extends Equatable {}

class GetRandomActivities extends ActivitiesEvent {
  final int howMany;

  GetRandomActivities(this.howMany);

  @override
  List<Object?> get props => [
        howMany,
      ];
}

class GetFilteredActivities extends ActivitiesEvent {
  final int howMany;
  final ActivityFilters? filters;

  GetFilteredActivities({
    required this.howMany,
    this.filters,
  });

  @override
  List<Object?> get props => [
        howMany,
        filters,
      ];
}

class UpdateActivityFilters extends ActivitiesEvent {
  final ActivityFilters filters;

  UpdateActivityFilters({required this.filters});

  @override
  List<Object?> get props => [filters];
}

class ResetFilteredActivities extends ActivitiesEvent {
  @override
  List<Object?> get props => [];
}

class ResetFilters extends ActivitiesEvent {
  @override
  List<Object?> get props => [];
}

class SelectedActivity extends ActivitiesEvent {
  final Activity? activity;

  SelectedActivity(this.activity);

  @override
  List<Object?> get props => [
        activity,
      ];
}
