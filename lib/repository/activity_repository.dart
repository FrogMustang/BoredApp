import 'dart:convert';

import 'package:bored_app/bloc/activity/activities_bloc.dart';
import 'package:bored_app/models/activity.dart';
import 'package:bored_app/utils.dart';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart';

class ActivitiesRepository {
  final Client _client = Client();

  Future<Either<String, List<Activity>>> getRandomActivities({
    required int howMany,
  }) async {
    logger.i('FETCHING $howMany RANDOM ACTIVITIES...');

    try {
      return _getUniqueActivities(
        howMany: howMany,
        type: ActivityType.random,
        getActivity: () async {
          return await getRandomActivity();
        },
      );
    } catch (e, stackTrace) {
      logger.e(
        "Failed to get random activities",
        error: e,
        stackTrace: stackTrace,
      );
      return Left(e.toString());
    }
  }

  Future<Either<String, Activity>> getRandomActivity() async {
    Response response = await _client.get(
      Uri.https(
        'boredapi.com',
        'api/activity/',
      ),
    );

    /// if something fails
    if (response.statusCode != 200 ||
        json.decode(response.body)['error'] != null) {
      String errorMessage = json.decode(response.body)['error'] ??
          'Failed to get random activities';

      logger.e('Failed to get random activities: $errorMessage');

      return Left(errorMessage);
    } else {
      logger.t(json.decode(response.body));

      return Right(
        Activity.fromRandomJSON(
          json.decode(response.body),
        ),
      );
    }
  }

  Future<Either<String, List<Activity>>> getFilteredActivities({
    required int howMany,
    ActivityFilters? filters,
  }) async {
    try {
      logger.i('FETCHING FILTERED ACTIVITIES \n'
          'HOW MANY: $howMany \n'
          'TYPE: ${filters?.activityCategory} \n'
          'PARTICIPANTS: ${filters?.participants} \n'
          'MIN PRICE: ${filters?.minPrice} \n'
          'MAX PRICE: ${filters?.maxPrice} \n'
          'MIN ACC: ${filters?.minAccessibility} \n'
          'MAX ACC: ${filters?.maxAccessibility} \n');

      return _getUniqueActivities(
        howMany: howMany,
        type: ActivityType.filtered,
        getActivity: () async {
          return await getFilteredActivity(
            filters: filters,
          );
        },
      );
    } catch (e, stackTrace) {
      logger.e(
        "Failed to get filtered activities",
        error: e,
        stackTrace: stackTrace,
      );
      return Left(e.toString());
    }
  }

  Future<Either<String, List<Activity>>> _getUniqueActivities({
    required int howMany,
    required ActivityType type,
    required Future<Either<String, Activity>> Function() getActivity,
  }) async {
    final String typeName = type.getName.toUpperCase();
    List<Activity> fetchedActivities = type.getExistingActivities;

    String? error;
    // Used to avoid  duplicates and try to fetch items again
    // until we get the desired amount or we only get duplicates
    int uniqueActivities = 0;

    while (uniqueActivities < howMany) {
      // keep track of how many duplicates we got
      int duplicates = 0;

      if (uniqueActivities > 0) {
        logger.d('TO FETCH: $howMany \n'
            'GOT duplicate $typeName activities, '
            'fetching a (new) batch...');
      }

      // fetch activities
      for (int i = 1; i <= howMany; i++) {
        final Either<String, Activity> res = await getActivity();

        res.fold(
          (err) {
            logger.e(
              'Failed to get $typeName activity',
              error: err,
            );
            // fetching failed so we have to break the loop
            uniqueActivities = howMany;
            error = err.toString();
          },
          (Activity activity) {
            // check if we already added this activity
            // avoided .contains() for finer control over the fields equality
            int index = fetchedActivities.indexWhere(
              (Activity a) => a.key == activity.key && a.name == activity.name,
            );

            // add the new activity
            if (index == -1) {
              uniqueActivities++;
              fetchedActivities.add(activity);
            } else {
              duplicates++;
            }
          },
        );

        if (error != null) {
          return Left(error!);
        }

        // if we only get duplicates or got enough activities, break the loop
        if (uniqueActivities == howMany || duplicates == howMany) {
          logger.i('FETCHED $uniqueActivities new $typeName activities');
          return Right(fetchedActivities);
        }
      }
    }

    logger.i('FETCHED $uniqueActivities new $typeName activities');
    return Right(fetchedActivities);
  }

  Future<Either<String, Activity>> getFilteredActivity({
    ActivityFilters? filters,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'type': filters?.activityCategory?.name,
        'minprice': filters?.minPrice,
        'maxpice': filters?.maxPrice,
        'participants': filters?.participants,
        'minaccessibility': filters?.minAccessibility,
        'maxaccessibility': filters?.maxAccessibility,
      }.map((key, value) {
        return MapEntry(key, value != null ? value.toString() : '');
      });

      if (filters?.activityCategory == null) {
        queryParams.remove('type');
      }

      Response response = await _client.get(
        Uri.https(
          'www.boredapi.com',
          '/api/activity',
          queryParams,
        ),
      );

      /// if something fails
      if (response.statusCode != 200 ||
          json.decode(response.body)['error'] != null) {
        String errorMessage = json.decode(response.body)['error'] ??
            'Failed to get a filtered activity';

        return Left(errorMessage);
      } else {
        logger.t('Filtered activity JSON: \n'
            '${json.decode(response.body)}');

        return Right(
          Activity.fromFilteredJSON(
            json.decode(response.body),
          ),
        );
      }
    } catch (error, stackTrace) {
      return Left('Failed to fetch a filtered activity: $error \n'
          'STACK TRACE: $stackTrace');
    }
  }
}
