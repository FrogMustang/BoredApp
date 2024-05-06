import 'package:bored_app/application.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

// define constants e.g. appId for adds, keys etc.

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  final Map<String, Level> logLevels = {
    'TRACE': Level.trace,
    'DEBUG': Level.debug,
    'INFO': Level.info,
    'WARNING': Level.warning,
    'ERROR': Level.error,
    'FATAL': Level.fatal,
  };
  Logger.level = logLevels[dotenv.env["LOGGER_LEVEL"]] ?? Level.trace;

  startApplication();
}
