import 'dart:math';
import 'dart:ui';

import 'package:bored_app/application.dart';
import 'package:bored_app/bloc/activity/activities_bloc.dart';
import 'package:bored_app/exceptions/activities_error.dart';
import 'package:bored_app/models/activity.dart';
import 'package:bored_app/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final activitiesController =
      ActivitiesController(activityBloc: getIt<ActivitiesBloc>());

  final ActivitiesBloc _activitiesBloc = getIt<ActivitiesBloc>();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.extentAfter < 300 &&
          _activitiesBloc.state.status != ActivitiesStatus.loading) {
        activitiesController.getRandomActivities(howMany: 10);
      }
    });

    activitiesController.getRandomActivities(howMany: 20);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          // get random activities error
          BlocListener<ActivitiesBloc, ActivitiesState>(
            bloc: _activitiesBloc,
            listenWhen: (previous, current) {
              return current.error is GetRandomActivitiesError;
            },
            listener: (context, state) {
              ActivitiesError error = state.error;

              showErrorToast(
                context,
                error.message ?? 'Failed to get random activities',
              );
            },
          ),
        ],
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Text(
                  'Activities',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              BlocBuilder<ActivitiesBloc, ActivitiesState>(
                bloc: _activitiesBloc,
                builder: (context, state) {
                  if ((state.status == ActivitiesStatus.fetched ||
                          state.status == ActivitiesStatus.loading) &&
                      state.activities.isNotEmpty) {
                    return _buildActivitiesScreen(
                      state.activities,
                      state.status,
                    );
                  }

                  return const Center(
                    child: CupertinoActivityIndicator(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivitiesScreen(
    List<Activity?> activities,
    ActivitiesStatus status,
  ) {
    return activities.isNotEmpty
        ? Expanded(
            child: ScrollConfiguration(
              behavior: NoMoreGlow(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ListView(
                  controller: _scrollController,
                  children: [
                    for (int i = 1; i <= activities.length; i++)
                      _buildActivity(activities[i - 1]!, i),
                    if (status == ActivitiesStatus.loading)
                      const CupertinoActivityIndicator(),
                  ],
                ),
              ),
            ),
          )
        : const SizedBox();
  }

  Widget _buildActivity(Activity activity, int index) {
    return Container(
      height: 180,
      width: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
          image: AssetImage(_getImage(activity.type)),
          fit: BoxFit.cover,
        ),
      ),
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
            child: Text(
              activity.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          Text(
            activity.type,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _getImage(String type) {
    int photoIndex = Random().nextInt(4) + 1;

    switch (type) {
      case 'education':
        return 'assets/images/education_1.jpg';
      case 'recreational':
        return 'assets/images/recreational_1.jpg';
      case 'social':
        return 'assets/images/social_1.jpg';
      case 'diy':
        return 'assets/images/diy_1.jpg';
      case 'charity':
        return 'assets/images/charity_1.jpg';
      case 'cooking':
        return 'assets/images/cooking_1.jpg';
      case 'relaxation':
        return 'assets/images/relax_1.jpg';
      case 'music':
        return 'assets/images/music_1.jpg';
      case 'busywork':
        return 'assets/images/busy_1.jpg';
      default:
        return 'assets/images/placeholder.jpg';
    }
  }
}
