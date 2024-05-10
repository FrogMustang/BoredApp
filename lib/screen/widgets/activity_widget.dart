import 'dart:ui';

import 'package:bored_app/app_router.dart';
import 'package:bored_app/application.dart';
import 'package:bored_app/bloc/activity/activities_bloc.dart';
import 'package:bored_app/models/activity.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ActivityWidget extends StatelessWidget {
  const ActivityWidget({
    super.key,
    required this.activity,
    required this.index,
    required this.status,
  });

  final Activity activity;

  /// Index of the activity inside the list of activities
  final int index;

  /// The status from the [ActivitiesBloc]
  final ActivitiesStatus status;

  @override
  Widget build(BuildContext context) {
    final ActivitiesBloc activitiesBloc = getIt<ActivitiesBloc>();

    return Container(
      height: 230,
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: GestureDetector(
        onTap: status == ActivitiesStatus.loading
            ? null
            : () {
                activitiesBloc.add(SelectedActivity(activity));
                context.pushNamed(AppRoute.detailsView.name);
              },
        child: Stack(
          children: [
            // ACTIVITY PHOTO BG
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Hero(
                  tag: activity,
                  child: ImageFiltered(
                    // change values to blur BG image
                    imageFilter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                    child: Image.asset(
                      activity.getImage(),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),

            // ACTIVITIES
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    activity.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      shadows: [
                        Shadow(
                          offset: const Offset(3, 3),
                          blurRadius: 10,
                          color: Colors.black.withOpacity(0.7),
                        ),
                        Shadow(
                          offset: const Offset(3, 3),
                          blurRadius: 30,
                          color: Colors.black.withOpacity(0.7),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _Chips(activity: activity),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chips extends StatelessWidget {
  const _Chips({
    required this.activity,
  });

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 5,
      children: [
        _Chip(
          child: Text(
            activity.type.toLowerCase(),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 10),
        _Chip(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.people, size: 16),
              const SizedBox(width: 3),
              Text(
                activity.participants.toString(),
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _Chip(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.accessibility_new, size: 16),
              const SizedBox(width: 3),
              Text(
                activity.accessibility.toStringAsFixed(2),
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _Chip(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.attach_money, size: 16),
              const SizedBox(width: 3),
              Text(
                activity.price.toStringAsFixed(2).toString(),
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 3,
      ),
      child: child,
    );
  }
}
