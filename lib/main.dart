import 'package:bored_app/application.dart';
import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';

// define constants e.g. appId for adds, keys etc.

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Logger.level = Level.debug;

  // define debug and production environment

  startApplication();
}