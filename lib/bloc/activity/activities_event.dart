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
  final String? type;
  final int? participants;
  final double? minPrice;
  final double? maxPrice;
  final double? minAccessibility;
  final double? maxAccessibility;

  GetFilteredActivities({
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
