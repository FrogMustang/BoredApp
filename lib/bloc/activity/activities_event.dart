part of 'activities_bloc.dart';

abstract class ActivitiesEvent extends Equatable {}

class _GetRandomActivities extends ActivitiesEvent {
  final int howMany;

  _GetRandomActivities(this.howMany);

  @override
  List<Object?> get props => [
        howMany,
      ];
}

class _GetFilteredActivities extends ActivitiesEvent {
  final int howMany;
  final String? type;
  final int? participants;
  final double? minPrice;
  final double? maxPrice;
  final double? minAccessibility;
  final double? maxAccessibility;

  _GetFilteredActivities({
    required this.howMany,
    this.type,
    this.participants,
    this.minPrice,
    this.maxPrice,
    this.minAccessibility,
    this.maxAccessibility,
  });

  @override
  List<Object?> get props => [
        howMany,
        type,
        participants,
        minPrice,
        maxPrice,
        minAccessibility,
        maxAccessibility,
      ];
}

class ResetFilteredActivities extends ActivitiesEvent {
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
