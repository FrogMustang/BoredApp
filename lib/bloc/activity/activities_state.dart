part of 'activities_bloc.dart';

enum ActivitiesStatus {
  neverFetched,
  loading,
  fetched,
  failed,
}

class ActivitiesState extends Equatable {
  final ActivitiesStatus status;
  final List<Activity?> activities;
  final dynamic error;

  const ActivitiesState._(
    this.status,
    this.activities,
    this.error,
  );

  factory ActivitiesState({
    ActivitiesStatus status = ActivitiesStatus.neverFetched,
    List<Activity?> activities = const [],
    dynamic error,
  }) {
    return ActivitiesState._(
      status,
      activities,
      error,
    );
  }

  ActivitiesState copyWith({
    ActivitiesStatus? status,
    List<Activity?>? activities,
    Optional<dynamic>? error,
  }) {
    return ActivitiesState(
      status: status ?? this.status,
      activities: activities ?? this.activities,
      error: error != null ? error.orNull : this.error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        activities,
        error,
      ];
}
