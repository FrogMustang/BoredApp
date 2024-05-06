import 'dart:io';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:bored_app/exceptions/activities_error.dart';
import 'package:bored_app/models/activity.dart';
import 'package:bored_app/repository/activity_repository.dart';
import 'package:bored_app/utils.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:quiver/core.dart';

part 'activities_event.dart';
part 'activities_state.dart';
part 'package:bored_app/controllers/activities_controller.dart';

class ActivitiesBloc extends Bloc<ActivitiesEvent, ActivitiesState> {
  final ActivitiesRepository activityRepo;

  ActivitiesBloc({
    required this.activityRepo,
  }) : super(const ActivitiesState()) {
    // transformer is just for show
    on<GetRandomActivities>(
      onGetRandomActivities,
      transformer: sequential(),
    );
    on<GetFilteredActivities>(onGetFilteredActivities);
    on<ResetFilteredActivities>(onResetFilteredActivities);
    on<SelectedActivity>(onSelectedActivity);
  }

  void onGetRandomActivities(
    GetRandomActivities event,
    Emitter<ActivitiesState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          randomStatus: ActivitiesStatus.loading,
          error: const Optional.absent(),
        ),
      );

      List<Activity> activities = await activityRepo.getRandomActivities(
        howMany: event.howMany,
      );

      emit(
        state.copyWith(
          randomStatus: ActivitiesStatus.fetched,
          randomActivities: activities,
          error: const Optional.absent(),
        ),
      );
    } on SocketException catch (e, stackTrace) {
      logger.e(
        'No internet. \n'
        '${e.message}',
        error: e,
        stackTrace: stackTrace,
      );

      // get activities failed
      emit(
        state.copyWith(
          randomStatus: ActivitiesStatus.failed,
          error: Optional.of(
            const GetActivitiesError(message: 'No internet connection'),
          ),
        ),
      );
    } on HttpException catch (e, stackTrace) {
      logger.e(
        'Activities not found. \n'
        '${e.message}',
        error: e,
        stackTrace: stackTrace,
      );

      emit(
        state.copyWith(
          randomStatus: ActivitiesStatus.failed,
          error: Optional.of(
            const GetActivitiesError(message: 'Activities not found'),
          ),
        ),
      );
    } on FormatException catch (e, stackTrace) {
      logger.e(
        'Activities not found. \n'
        '${e.message}',
        error: e,
        stackTrace: stackTrace,
      );

      emit(
        state.copyWith(
          randomStatus: ActivitiesStatus.failed,
          error: Optional.of(
            const GetActivitiesError(message: 'Activities not found'),
          ),
        ),
      );
    } catch (e, stackTrace) {
      logger.e(
        'Get activities unknown error. \n'
        '${e.toString()}',
        error: e,
        stackTrace: stackTrace,
      );

      emit(
        state.copyWith(
          randomStatus: ActivitiesStatus.failed,
          error: Optional.of(e),
        ),
      );
    }
  }

  void onGetFilteredActivities(
    GetFilteredActivities event,
    Emitter<ActivitiesState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          filteredStatus: ActivitiesStatus.loading,
          error: const Optional.absent(),
        ),
      );

      Either<String, List<Activity>> result =
          await activityRepo.getFilteredActivities(
        howMany: event.howMany,
        type: event.type,
        participants: event.participants,
        minPrice: event.minPrice,
        maxPrice: event.maxPrice,
        minAccessibility: event.minAccessibility,
        maxAccessibility: event.maxAccessibility,
      );

      result.fold(
        (String error) {
          emit(
            state.copyWith(
              filteredStatus: ActivitiesStatus.failed,
              error: Optional.of(
                GetActivitiesError(message: error.toString()),
              ),
            ),
          );
        },
        (filteredActivities) {
          emit(
            state.copyWith(
              filteredStatus: ActivitiesStatus.fetched,
              filteredActivities: filteredActivities,
              error: const Optional.absent(),
            ),
          );
        },
      );
    } on SocketException catch (e, stackTrace) {
      logger.e(
        'No internet. \n'
        '${e.message}',
        error: e,
        stackTrace: stackTrace,
      );

      emit(
        state.copyWith(
          filteredStatus: ActivitiesStatus.failed,
          error: Optional.of(
            const GetActivitiesError(message: 'No internet connection'),
          ),
        ),
      );
    } on HttpException catch (e, stackTrace) {
      logger.e(
        'Activities not found. \n'
        '${e.message}',
        error: e,
        stackTrace: stackTrace,
      );

      // get activities failed
      emit(
        state.copyWith(
          filteredStatus: ActivitiesStatus.failed,
          error: Optional.of(
            const GetActivitiesError(message: 'Activities not found'),
          ),
        ),
      );
    } on FormatException catch (e, stackTrace) {
      logger.e(
        'Activities not found. \n'
        '${e.message}',
        error: e,
        stackTrace: stackTrace,
      );

      // get activities failed
      emit(
        state.copyWith(
          filteredStatus: ActivitiesStatus.failed,
          error: Optional.of(
            const GetActivitiesError(message: 'Activities not found'),
          ),
        ),
      );
    } catch (e, stackTrace) {
      logger.e(
        'Get activities unknown error. \n'
        '${e.toString()}',
        error: e,
        stackTrace: stackTrace,
      );

      emit(
        state.copyWith(
          filteredStatus: ActivitiesStatus.failed,
          error: Optional.of(e),
        ),
      );
    }
  }

  void onResetFilteredActivities(
    ResetFilteredActivities event,
    Emitter<ActivitiesState> emit,
  ) {
    emit(
      state.copyWith(
        filteredActivities: [],
      ),
    );
  }

  void onSelectedActivity(
    SelectedActivity event,
    Emitter<ActivitiesState> emit,
  ) {
    if (event.activity != null) {
      emit(
        state.copyWith(
          selectedActivity: Optional.fromNullable(event.activity),
        ),
      );
    } else {
      emit(
        state.copyWith(
          selectedActivity: const Optional.absent(),
        ),
      );
    }
  }
}
