import 'package:bored_app/application.dart';
import 'package:bored_app/bloc/activity/activities_bloc.dart';
import 'package:bored_app/models/activity.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger(
  printer: PrettyPrinter(
    methodCount: 5,
  ),
);

void showErrorToast(
  BuildContext context,
  String text, {
  ToastGravity? gravity,
}) {
  showToast(
    context,
    text,
    bgColor: Colors.red,
    textColor: Colors.white,
    icon: Icons.error,
    gravity: gravity ?? ToastGravity.BOTTOM,
  );
}

void showToast(
  BuildContext context,
  String text, {
  Color? bgColor,
  Color? textColor,
  IconData? icon,
  ToastGravity? gravity,
}) {
  var fToast = FToast();
  fToast.init(context);

  // cancel any other toast currently shown
  fToast.removeCustomToast();

  // Hide keyboard if there is one,
  // otherwise the toast will show behind the keyboard
  FocusScope.of(context).unfocus();

  fToast.showToast(
    child: Container(
      decoration: BoxDecoration(
        color: bgColor ?? Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 10,
      ),
      child: Row(
        children: [
          icon != null
              ? Icon(
                  icon,
                  color: textColor ?? Colors.black,
                )
              : const SizedBox(),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: textColor ?? Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    ),
    toastDuration: const Duration(seconds: 2),
    gravity: gravity ?? ToastGravity.BOTTOM,
  );
}

/// Used to select the category of activities
/// (e.g. social, educational, busywork etc.)
enum ActivityCategory {
  education(name: 'education'),
  recreational(name: 'recreational'),
  social(name: 'social'),
  diy(name: 'diy'),
  charity(name: 'charity'),
  cooking(name: 'cooking'),
  relaxation(name: 'relaxation'),
  music(name: 'music'),
  busywork(name: 'busywork');

  const ActivityCategory({required this.name});

  final String name;
}

/// Used to easily differentiate between
/// random activities and filtered activities
enum ActivityType {
  random(),
  filtered();

  const ActivityType();

  String get getName {
    switch (this) {
      case ActivityType.random:
        return "random";

      case ActivityType.filtered:
        return "filtered";

      default:
        throw UnimplementedError("Please provide a name "
            "for the given type: $this");
    }
  }

  List<Activity> get getExistingActivities {
    switch (this) {
      case ActivityType.random:
        return List.from(
          getIt.get<ActivitiesBloc>().state.randomActivities,
        );

      case ActivityType.filtered:
        return List.from(
          getIt.get<ActivitiesBloc>().state.filteredActivities,
        );

      default:
        throw UnimplementedError("Please provide a list of existing activities "
            "for the given type: $this");
    }
  }
}

/// CLASS USED TO REMOVE THE SCROLL GLOW FROM LISTS
class NoMoreGlow extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
