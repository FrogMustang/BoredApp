import 'dart:convert';

import 'package:bored_app/application.dart';
import 'package:bored_app/bloc/activity/activities_bloc.dart';
import 'package:bored_app/exceptions/activities_error.dart';
import 'package:bored_app/models/activity.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class ActivitiesRepository {
  Logger log = Logger();
  final _client = http.Client();

  Future<List<Activity?>> getRandomActivities({required int howMany}) async {
    List<Activity?> res = List.from(
      getIt<ActivitiesBloc>().state.randomActivities,
    );

    for (int i = 1; i <= howMany; i++) {
      Activity? activity = await getRandomActivity();
      Activity? existingActivity = res.firstWhere(
          (Activity? a) => a != null && a.key == activity?.key,
          orElse: () => null);

      if (existingActivity == null) {
        res.add(activity);
      }
    }
    return res;
  }

  Future<Activity?> getRandomActivity() async {
    // log.i('Make API request to fetch random activity...');

    http.Response response = await _client.get(Uri.https(
      'www.boredapi.com',
      'api/activity/',
    ));

    /// if something fails
    if (response.statusCode != 200 ||
        json.decode(response.body)['error'] != null) {
      log.e('Failed to get random activities');
      String errorMessage = json.decode(response.body)['error'] ??
          'Failed to get random activities';
      throw GetActivitiesError(message: errorMessage);
    } else {
      log.v(json.decode(response.body));
      return Activity.fromRandomJSON(json.decode(response.body));
    }
  }

  Future<List<Activity?>> getFilteredActivities({
    required int howMany,
    String? type,
    double? price,
    int? participants,
    double? minPrice,
    double? maxPrice,
    double? minAccessibility,
    double? maxAccessibility,
  }) async {
    List<Activity?> res = List.from(
      getIt<ActivitiesBloc>().state.filteredActivities,
    );
    for (int i = 1; i <= howMany; i++) {
      Activity? activity = await getFilteredActivity(
        type: type,
        price: price,
        participants: participants,
        minPrice: minPrice,
        maxPrice: maxPrice,
        minAccessibility: minAccessibility,
        maxAccessibility: maxAccessibility,
      );

      // check if we already added this activity
      Activity? existingActivity = res.firstWhere(
        (Activity? a) => a != null && a.key == activity?.key,
        orElse: () => null,
      );

      // if we actually got an activity with the requested number of participants
      if (participants != null && activity?.participants != participants) {
        throw const GetActivitiesError(message: 'No activity found');
      }

      // check if we already added the activity
      if (existingActivity == null) {
        res.add(activity);
      }
    }
    return res;
  }

  Future<Activity?> getFilteredActivity({
    String? type,
    double? price,
    int? participants,
    double? minPrice,
    double? maxPrice,
    double? minAccessibility,
    double? maxAccessibility,
  }) async {
    // log.i('Make API request to fetch filtered activity...');

    print('MinPrice: $minPrice MaxPrice: $maxPrice');

    minPrice = minPrice ?? 0.0;
    maxPrice = maxPrice ?? 1.0;
    participants = participants ?? 1;
    minAccessibility = minAccessibility ?? 0.0;
    maxAccessibility = maxAccessibility ?? 1.0;

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

    http.Response response = await _client.get(Uri.https(
      'www.boredapi.com',
      '/api/activity',
      queryParams,
    ));

    /// if something fails
    if (response.statusCode != 200 ||
        json.decode(response.body)['error'] != null) {
      log.e('Failed to get filtered activities');

      String errorMessage = json.decode(response.body)['error'] ??
          'Failed to get filtered activities';
      throw GetActivitiesError(message: errorMessage);
    } else {
      log.d('JSON: ${json.decode(response.body)}');
      return Activity.fromFilteredJSON(json.decode(response.body));
    }
  }
}
