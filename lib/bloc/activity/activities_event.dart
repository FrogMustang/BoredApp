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
