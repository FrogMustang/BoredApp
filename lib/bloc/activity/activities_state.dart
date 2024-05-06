part of 'activities_bloc.dart';

enum ActivitiesStatus {
  neverFetched,
  loading,
  fetched,
  failed,
  noMoreActivitiesFound,
}

final Logger _log = Logger(
    printer: PrettyPrinter(
  colors: true,
  printEmojis: true,
  printTime: true,
));

class ActivitiesState extends Equatable {
  final ActivitiesStatus randomStatus;
  final List<Activity> randomActivities;
  final Activity? selectedActivity;
  final ActivitiesStatus filteredStatus;
  final List<Activity> filteredActivities;
  final dynamic error;

  const ActivitiesState({
    this.randomStatus = ActivitiesStatus.neverFetched,
    this.randomActivities = const [],
    this.selectedActivity,
    this.filteredStatus = ActivitiesStatus.neverFetched,
    this.filteredActivities = const [],
    this.error,
  });

  ActivitiesState copyWith({
    ActivitiesStatus? randomStatus,
    List<Activity>? randomActivities,
    Optional<Activity>? selectedActivity,
    ActivitiesStatus? filteredStatus,
    List<Activity>? filteredActivities,
    Optional<dynamic>? error,
  }) {
    ActivitiesState newState = ActivitiesState(
      randomStatus: randomStatus ?? this.randomStatus,
      randomActivities: randomActivities ?? this.randomActivities,
      selectedActivity: selectedActivity != null
          ? selectedActivity.orNull
          : this.selectedActivity,
      filteredStatus: filteredStatus ?? this.filteredStatus,
      filteredActivities: filteredActivities ?? this.filteredActivities,
      error: error != null ? error.orNull : this.error,
    );

    _log.t('COPY WITH --- Old state: $this \n'
        'New state: $newState');
    return newState;
  }

  @override
  List<Object?> get props => [
        randomStatus,
        randomActivities,
        selectedActivity,
        filteredActivities,
        filteredStatus,
        error,
      ];

  @override
  String toString() {
    return 'Status: $randomStatus \n'
        'Selected activity: $selectedActivity \n'
        'Filtered Activities: $filteredActivities \n'
        'Error: $error \n';
  }
}
