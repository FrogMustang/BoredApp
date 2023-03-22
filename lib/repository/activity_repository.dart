import 'dart:convert';

import 'package:bored_app/models/activity.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class ActivitiesRepository {
  Logger log = Logger();
  final _client = http.Client();

  /// Fetch [howMany] random items from the API
  Future<List<Activity?>> getRandomActivities({required int howMany}) async {
    List<Activity?> res = [];
    for(int i = 1 ; i <= howMany ; i++) {
      Activity? activity = await getRandomActivity();
      res.add(activity);
    }
    return res;
  }

  Future<Activity?> getRandomActivity() async {
    log.i('Make API request to fetch random activity...');

    http.Response response = await _client.get(Uri.https(
      'www.boredapi.com',
      'api/activity/',
    ));

    /// if something fails
    if (response.statusCode != 200) {
      log.e('Failed to fetch random activities');

      // throw GetRandomActivitiesError(message: 'Failed to fetch random activities');
      return null;
    } else {
      log.v(json.decode(response.body));
      return Activity.fromJSON(json.decode(response.body));
    }
  }
}
