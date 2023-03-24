import 'dart:ui';

import 'package:bored_app/application.dart';
import 'package:bored_app/bloc/activity/activities_bloc.dart';
import 'package:bored_app/models/activity.dart';
import 'package:bored_app/screen/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class ActivityDetailsScreen extends StatefulWidget {
  const ActivityDetailsScreen({Key? key}) : super(key: key);

  @override
  State<ActivityDetailsScreen> createState() => _ActivityDetailsScreenState();
}

class _ActivityDetailsScreenState extends State<ActivityDetailsScreen> {
  final _activitiesBloc = getIt<ActivitiesBloc>();
  final activitiesController = ActivitiesController(
    activityBloc: getIt<ActivitiesBloc>(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ActivitiesBloc, ActivitiesState>(
        bloc: _activitiesBloc,
        builder: (context, state) {
          if (state.selectedActivity != null) {
            return SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  _buildActivityPhotoBG(state),
                  _buildActivityDetails(state),
                ],
              ),
            );
          }

          return const LoadingScreen();
        },
      ),
    );
  }

  Widget _buildActivityPhotoBG(ActivitiesState state) {
    return Positioned.fill(
      child: Hero(
        tag: state.selectedActivity!,
        child: ImageFiltered(
          // change values to blur BG image
          imageFilter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Image.asset(
            state.selectedActivity!.getImage(),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildActivityDetails(ActivitiesState state) {
    return BlocBuilder<ActivitiesBloc, ActivitiesState>(
      bloc: _activitiesBloc,
      builder: (context, state) {
        Activity activity = state.selectedActivity!;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: const Offset(2, 2),
                            blurRadius: 10,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ],
                      ),
                      onPressed: () {
                        context.pop();

                        Future.delayed(const Duration(milliseconds: 300), () {
                          activitiesController.selectedActivity(activity: null);
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                  Hero(
                    tag: activity.key + activity.name,
                    child: Material(
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _showTitle(activity),
                          const SizedBox(height: 10),
                          _showChips(activity),
                        ],
                      ),
                    ),
                  ),
                  ..._buildDetailsSection(activity),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _showTitle(Activity activity) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Text(
        activity.name,
        maxLines: 7,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 24,
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
    );
  }

  Widget _showChips(Activity activity) {
    return Wrap(
      runSpacing: 5,
      children: [
        _buildChip(
          Text(
            activity.type.toLowerCase(),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 10),
        _buildChip(
          Row(
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
        _buildChip(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.accessibility_new, size: 16),
              const SizedBox(width: 3),
              Text(
                activity.accessibility.toString(),
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _buildChip(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.attach_money, size: 16),
              const SizedBox(width: 3),
              Text(
                activity.price.toString(),
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

  Widget _buildChip(Widget child) {
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

  List<Widget> _buildDetailsSection(Activity activity) {
    return [
      const SizedBox(height: 40),
      Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 24,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            const Divider(
              color: Colors.black,
              height: 2.0,
            ),
            const SizedBox(height: 10),
            Text(
              'Key: ${activity.key}',
              style: const TextStyle(
                // fontSize: 16,
                // fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            if (activity.link?.isNotEmpty == true) ...[
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  final link = Uri.parse(activity.link.toString());
                  launchUrl(link);
                },
                child: Text(
                  'Link: ${activity.link.toString()}',
                ),
              ),
            ],
            const SizedBox(height: 10),
          ],
        ),
      ),
    ];
  }
}
