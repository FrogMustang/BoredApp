import 'dart:async';
import 'dart:io';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:bored_app/exceptions/activities_error.dart';
import 'package:bored_app/models/activity.dart';
import 'package:bored_app/repository/activity_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:quiver/core.dart';

part 'activities_event.dart';

part 'activities_state.dart';

part 'package:bored_app/controllers/activities_controller.dart';

class ActivitiesBloc extends Bloc<ActivitiesEvent, ActivitiesState> {
  Logger log = Logger();
  final ActivitiesRepository activityRepo;

  ActivitiesBloc({
    required this.activityRepo,
  }) : super(ActivitiesState()) {
    on<ActivitiesEvent>(_onEvent, transformer: sequential<ActivitiesEvent>());
  }

  FutureOr<void> _onEvent(
    ActivitiesEvent event,
    Emitter<ActivitiesState> emit,
  ) {
    log.d('New event: $event \n');

    if (event is _GetRandomActivities) {
      return _onGetRandomActivities(
        emit: emit,
        event: event,
      );
    } else if (event is _GetFilteredActivities) {
      return _onGetFilteredActivities(emit: emit, event: event);
    } else if (event is ResetFilteredActivities) {
      return _onResetFilteredActivities(emit: emit, event: event);
    } else if (event is SelectedActivity) {
      return _onSelectedActivity(emit: emit, event: event);
    }
  }

  Future<void> _onGetRandomActivities({
    required Emitter<ActivitiesState> emit,
    required _GetRandomActivities event,
  }) async {
    try {
      // fetching activities, so status is loading
      emit(state.copyWith(
        randomStatus: ActivitiesStatus.loading,
        error: const Optional.absent(),
      ));

      // get activities
      List<Activity?> activities = await activityRepo.getRandomActivities(
        howMany: event.howMany,
      );

      // activities fetched, so status is fetched
      emit(state.copyWith(
        randomStatus: ActivitiesStatus.fetched,
        randomActivities: activities,
        error: const Optional.absent(),
      ));
    } on SocketException catch (e, stackTrace) {
      log.e(
        'No internet. \n'
        '${e.message}',
        e,
        stackTrace,
      );

      // get activities failed
      emit(state.copyWith(
        randomStatus: ActivitiesStatus.failed,
        error: Optional.of(
          const GetActivitiesError(message: 'No internet connection'),
        ),
      ));
    } on HttpException catch (e, stackTrace) {
      log.e(
        'Activities not found. \n'
        '${e.message}',
        e,
        stackTrace,
      );

      // get activities failed
      emit(state.copyWith(
        randomStatus: ActivitiesStatus.failed,
        error: Optional.of(
          const GetActivitiesError(message: 'Activities not found'),
        ),
      ));
    } on FormatException catch (e, stackTrace) {
      log.e(
        'Activities not found. \n'
        '${e.message}',
        e,
        stackTrace,
      );

      // get activities failed
      emit(state.copyWith(
        randomStatus: ActivitiesStatus.failed,
        error: Optional.of(
          const GetActivitiesError(message: 'Activities not found'),
        ),
      ));
    } catch (e, stackTrace) {
      log.e(
        'Get activities unknown error. \n'
        '${e.toString()}',
        e,
        stackTrace,
      );

      emit(state.copyWith(
        randomStatus: ActivitiesStatus.failed,
        error: Optional.of(e),
      ));
    }
  }

  Future<void> _onGetFilteredActivities({
    required Emitter<ActivitiesState> emit,
    required _GetFilteredActivities event,
  }) async {
    try {
      // fetching activities, so status is loading
      emit(state.copyWith(
        filteredStatus: ActivitiesStatus.loading,
        error: const Optional.absent(),
      ));

      // get activities
      List<Activity?> filteredActivities =
          await activityRepo.getFilteredActivities(
        howMany: event.howMany,
        type: event.type,
        participants: event.participants,
        minPrice: event.minPrice,
        maxPrice: event.maxPrice,
        minAccessibility: event.minAccessibility,
        maxAccessibility: event.maxAccessibility,
      );

      // activities fetched, so status is fetched
      emit(state.copyWith(
        filteredStatus: ActivitiesStatus.fetched,
        filteredActivities: filteredActivities,
        error: const Optional.absent(),
      ));
    } on SocketException catch (e, stackTrace) {
      log.e(
        'No internet. \n'
        '${e.message}',
        e,
        stackTrace,
      );

      // get activities failed
      emit(state.copyWith(
        filteredStatus: ActivitiesStatus.failed,
        error: Optional.of(
          const GetActivitiesError(message: 'No internet connection'),
        ),
      ));
    } on HttpException catch (e, stackTrace) {
      log.e(
        'Activities not found. \n'
        '${e.message}',
        e,
        stackTrace,
      );

      // get activities failed
      emit(state.copyWith(
        filteredStatus: ActivitiesStatus.failed,
        error: Optional.of(
          const GetActivitiesError(message: 'Activities not found'),
        ),
      ));
    } on FormatException catch (e, stackTrace) {
      log.e(
        'Activities not found. \n'
        '${e.message}',
        e,
        stackTrace,
      );

      // get activities failed
      emit(state.copyWith(
        filteredStatus: ActivitiesStatus.failed,
        error: Optional.of(
          const GetActivitiesError(message: 'Activities not found'),
        ),
      ));
    } catch (e, stackTrace) {
      log.e(
        'Get activities unknown error. \n'
        '${e.toString()}',
        e,
        stackTrace,
      );

      emit(state.copyWith(
        filteredStatus: ActivitiesStatus.failed,
        error: Optional.of(e),
      ));
    }
  }

  Future<void> _onResetFilteredActivities({
    required Emitter<ActivitiesState> emit,
    required ResetFilteredActivities event,
  }) async {
    emit(state.copyWith(
      filteredActivities: [],
    ));
  }

  Future<void> _onSelectedActivity({
    required Emitter<ActivitiesState> emit,
    required SelectedActivity event,
  }) async {
    if (event.activity != null) {
      emit(state.copyWith(
        selectedActivity: Optional.fromNullable(event.activity),
      ));
    } else {
      emit(state.copyWith(
        selectedActivity: const Optional.absent(),
      ));
    }
  }
}
