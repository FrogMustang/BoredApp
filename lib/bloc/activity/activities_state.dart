part of 'activities_bloc.dart';

enum ActivitiesStatus {
  neverFetched,
  loading,
  fetched,
  failed,
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
  final ActivityFilters? filters;
  final ActivitiesStatus filteredStatus;
  final List<Activity> filteredActivities;
  final dynamic error;

  const ActivitiesState({
    this.randomStatus = ActivitiesStatus.neverFetched,
    this.randomActivities = const [],
    this.selectedActivity,
    this.filters = const ActivityFilters(),
    this.filteredStatus = ActivitiesStatus.neverFetched,
    this.filteredActivities = const [],
    this.error,
  });

  ActivitiesState copyWith({
    ActivitiesStatus? randomStatus,
    List<Activity>? randomActivities,
    Optional<Activity>? selectedActivity,
    Optional<ActivityFilters>? filters,
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
      filters: filters != null ? filters.orNull : this.filters,
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
        filters,
        filteredStatus,
        filteredActivities,
        error,
      ];

  @override
  String toString() {
    return 'Status: $randomStatus \n'
        'Selected activity: $selectedActivity \n'
        'Filters: $filters \n'
        'Filtered Activities: $filteredActivities \n'
        'Error: $error \n';
  }
}

class ActivityFilters extends Equatable {
  final ActivityCategory? activityCategory;
  final int? participants;
  final double minPrice;
  final double maxPrice;
  final double minAccessibility;
  final double maxAccessibility;

  const ActivityFilters({
    this.activityCategory,
    this.participants,
    this.minPrice = 0.0,
    this.maxPrice = 1.0,
    this.minAccessibility = 0.0,
    this.maxAccessibility = 1.0,
  });

  ActivityFilters copyWith({
    ActivityCategory? activityCategory,
    int? participants,
    double? minPrice,
    double? maxPrice,
    double? minAccessibility,
    double? maxAccessibility,
  }) {
    return ActivityFilters(
      activityCategory: activityCategory ?? this.activityCategory,
      participants: participants ?? this.participants,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minAccessibility: minAccessibility ?? this.minAccessibility,
      maxAccessibility: maxAccessibility ?? this.maxAccessibility,
    );
  }

  @override
  List<Object?> get props => [
        activityCategory,
        participants,
        minPrice,
        maxPrice,
        minAccessibility,
        maxAccessibility,
      ];
}
