import 'dart:convert';

import 'package:bored_app/application.dart';
import 'package:bored_app/bloc/activity/activities_bloc.dart';
import 'package:bored_app/models/activity.dart';
import 'package:bored_app/utils.dart';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart';

class ActivitiesRepository {
  final Client _client = Client();

  Future<List<Activity>> getRandomActivities({required int howMany}) async {
    logger.i('FETCHING $howMany RANDOM ACTIVITIES...');

    List<Activity> result = List.from(
      getIt<ActivitiesBloc>().state.randomActivities,
    );

    for (int i = 1; i <= howMany; i++) {
      final Either<String, Activity> res = await getRandomActivity();

      res.fold(
        (err) {},
        (Activity activity) {
          int index = result.indexWhere(
            (Activity a) => a.key == activity.key,
          );

          if (index == -1) {
            result.add(activity);
          }
        },
      );
    }
    return result;
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
    String? type,
    double? price,
    int? participants,
    double? minPrice,
    double? maxPrice,
    double? minAccessibility,
    double? maxAccessibility,
  }) async {
    try {
      participants ??= 1;
      minPrice ??= 0.0;
      maxPrice ??= 1.0;
      minAccessibility ??= 0.0;
      maxAccessibility ??= 1.0;

      logger.i('FETCHING FILTERED ACTIVITIES \n'
          'HOW MANY: $howMany \n'
          'TYPE: $type \n'
          'PRICE: $price \n'
          'PARTICIPANTS: $participants \n'
          'MIN PRICE: $minPrice \n'
          'MAX PRICE: $maxPrice \n'
          'MIN ACC: $minAccessibility \n'
          'MAX ACC: $maxAccessibility \n');

      List<Activity> fetchedActivities = [];

      String? error;
      // Used to avoid  duplicates and try to fetch items again
      // until we get the desired amount or we only get duplicates
      int uniqueActivity = 0;

      while (uniqueActivity < howMany) {
        // keep track of how many duplicates we got
        int duplicates = 0;

        if (uniqueActivity > 0) {
          logger.d('Got duplicate activities, fetching a new batch...');
        }

        // fetch activities
        for (int i = 1; i <= howMany; i++) {
          final Either<String, Activity> res = await getFilteredActivity(
            type: type,
            participants: participants,
            minPrice: minPrice,
            maxPrice: maxPrice,
            minAccessibility: minAccessibility,
            maxAccessibility: maxAccessibility,
          );

          res.fold(
            (err) {
              logger.e(
                'Failed to get filtered activities',
                error: err,
              );
              // fetching failed so we have to break the loop
              uniqueActivity = howMany;
              error = err.toString();
            },
            (Activity activity) {
              // check if we already added this activity
              // avoided .contains() for finer control over the fields equality
              int index = fetchedActivities.indexWhere(
                (Activity a) =>
                    a.key == activity.key && a.name == activity.name,
              );

              // add the new activity
              if (index == -1) {
                uniqueActivity++;
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
          if (uniqueActivity == howMany || duplicates == howMany) {
            break;
          }
        }
      }

      List<Activity> activitiesInState = List.from(
        getIt<ActivitiesBloc>().state.filteredActivities,
      );
      fetchedActivities.where(
        (a) =>
            activitiesInState.indexWhere(
              (aInState) => a.key == aInState.key,
            ) ==
            -1,
      );

      logger.i('FETCHED $uniqueActivity new filtered activities');
      return Right(fetchedActivities);
    } catch (e, stackTrace) {
      logger.e(
        "Failed to get filtered activities",
        error: e,
        stackTrace: stackTrace,
      );
      return const Left('');
    }
  }

  Future<Either<String, Activity>> getFilteredActivity({
    String? type,
    int? participants,
    double? minPrice,
    double? maxPrice,
    double? minAccessibility,
    double? maxAccessibility,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'type': type,
        'minprice': minPrice,
        'maxpice': maxPrice,
        'participants': participants,
        'minaccessibility': minAccessibility,
        'maxaccessibility': maxAccessibility,
      }.map((key, value) => MapEntry(key, value.toString()));

      if (type == null) {
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
