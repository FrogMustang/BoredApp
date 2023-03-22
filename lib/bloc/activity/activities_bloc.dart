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
  }) : super(ActivitiesState(status: ActivitiesStatus.neverFetched)) {
    on<ActivitiesEvent>(_onEvent, transformer: sequential<ActivitiesEvent>());
  }

  FutureOr<void> _onEvent(
    ActivitiesEvent event,
    Emitter<ActivitiesState> emit,
  ) {
    if (event is _GetRandomActivities) {
      return _onGetRandomActivities(
        emit: emit,
        event: event,
      );
    }
  }

  Future<void> _onGetRandomActivities({
    required Emitter<ActivitiesState> emit,
    required _GetRandomActivities event,
  }) async {
    try {
      // fetching activities, so status is loading
      emit(state.copyWith(
        status: ActivitiesStatus.loading,
        error: const Optional.absent(),
      ));

      // get activities
      Iterable<Activity?> activities = await activityRepo.getRandomActivities(
        howMany: event.howMany,
      );

      // append the newly fetched activities to the existing ones
      List<Activity?> newActivities = List.from(state.activities);
      newActivities.addAll(activities);

      // activities fetched, so status is fetched
      emit(state.copyWith(
        status: ActivitiesStatus.fetched,
        activities: newActivities,
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
        status: ActivitiesStatus.failed,
        error: Optional.of(
          const GetRandomActivitiesError(message: 'No internet connection'),
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
        status: ActivitiesStatus.failed,
        error: Optional.of(
          const GetRandomActivitiesError(message: 'Activities not found'),
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
        status: ActivitiesStatus.failed,
        error: Optional.of(
          const GetRandomActivitiesError(message: 'Activities not found'),
        ),
      ));
    } catch (e, stackTrace) {
      log.e(
        'Get random activities unknown error. \n'
        '${e.toString()}',
        e,
        stackTrace,
      );

      emit(state.copyWith(
        status: ActivitiesStatus.failed,
        error: Optional.of(GetRandomActivitiesError.unknown),
      ));
    }
  }
}
