import 'dart:ui';

import 'package:bored_app/app_router.dart';
import 'package:bored_app/application.dart';
import 'package:bored_app/bloc/activity/activities_bloc.dart';
import 'package:bored_app/exceptions/activities_error.dart';
import 'package:bored_app/models/activity.dart';
import 'package:bored_app/screen/activities_not_found.dart';
import 'package:bored_app/screen/error_screen.dart';
import 'package:bored_app/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final activitiesController = ActivitiesController(
    activityBloc: getIt<ActivitiesBloc>(),
  );

  final _activitiesBloc = getIt<ActivitiesBloc>();

  int _selectedTab = 0;
  final List<String> _tabTitles = ['Activities', 'Help me find an activity'];

  int _selectedTypeChip = -1;
  final List<String> _typeChips = [
    'education',
    'recreational',
    'social',
    'diy',
    'charity',
    'cooking',
    'relaxation',
    'music',
    'busywork',
  ];

  int _participants = 1;
  RangeValues _price = const RangeValues(0.00, 1.00);
  RangeValues _accessibility = const RangeValues(0.00, 1.00);

  void randomScrollListener() {
    activitiesController.getRandomActivities(howMany: 10);
  }

  void filteredScrollListener() {
    activitiesController.getFilteredActivities(
      howMany: 10,
      type: _selectedTypeChip == -1 ? null : _typeChips[_selectedTypeChip],
      participants: _participants,
      minPrice: _price.start,
      maxPrice: _price.end,
      minAccessibility: _accessibility.start,
      maxAccessibility: _accessibility.end,
    );
  }

  final randomScrollController = ScrollController();
  final filteredScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    activitiesController.getRandomActivities(howMany: 20);

    randomScrollController.addListener(() {
      if (randomScrollController.position.extentAfter < 500 &&
          _activitiesBloc.state.randomStatus != ActivitiesStatus.loading) {
        randomScrollListener();
      }
    });

    activitiesController.getFilteredActivities(howMany: 20);

    filteredScrollController.addListener(() {
      if (filteredScrollController.position.extentAfter < 500 &&
          _activitiesBloc.state.filteredStatus != ActivitiesStatus.loading) {
        filteredScrollListener();
      }
    });
  }

  @override
  void dispose() {
    randomScrollController.dispose();
    filteredScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        currentIndex: _selectedTab,
        selectedItemColor: Colors.teal,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        unselectedItemColor: Colors.black.withOpacity(0.5),
        elevation: 10,
        onTap: (index) {
          setState(() {
            _selectedTab = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            label: _tabTitles[0],
            icon: const Icon(Icons.shuffle),
          ),
          BottomNavigationBarItem(
            label: _tabTitles[1],
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ActivitiesBloc, ActivitiesState>(
            bloc: getIt<ActivitiesBloc>(),
            listenWhen: (previous, current) {
              return current.error is ActivitiesError;
            },
            listener: (context, state) {
              ActivitiesError error = state.error;

              showErrorToast(
                context,
                error.message ?? 'Failed to get activities',
              );
            },
          ),
        ],
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        _tabTitles[_selectedTab],
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _selectedTab == 1
                        ? IconButton(
                            icon: const Icon(
                              Icons.filter_list_rounded,
                              size: 24,
                            ),
                            onPressed: () async {
                              await showDialog(
                                context: context,
                                builder: (dialogContext) {
                                  return StatefulBuilder(
                                    builder: (_, setState) {
                                      return AlertDialog(
                                        backgroundColor:
                                            Colors.black.withOpacity(0.7),
                                        content: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Type',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              const Divider(
                                                color: Colors.white,
                                                height: 2,
                                              ),
                                              const SizedBox(height: 10),
                                              _buildTypeChips(setState),
                                              const SizedBox(height: 30),
                                              ..._buildPriceSlider(setState),
                                              const SizedBox(height: 30),
                                              ..._buildParticipantsSlider(
                                                  setState),
                                              const SizedBox(height: 30),
                                              ..._buildAccessibilitySlider(
                                                  setState),
                                              const SizedBox(height: 30),
                                              _buildApplyFiltersButton(
                                                  setState, dialogContext),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          )
                        : const SizedBox(height: 50),
                  ],
                ),
              ),
              _buildActivitiesList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivitiesList() {
    if (_selectedTab == 0) {
      return BlocBuilder<ActivitiesBloc, ActivitiesState>(
        bloc: _activitiesBloc,
        builder: (context, state) {
          if ((state.randomStatus == ActivitiesStatus.fetched ||
                  state.randomStatus == ActivitiesStatus.loading) &&
              state.randomActivities.isNotEmpty) {
            return Expanded(
              child: ScrollConfiguration(
                behavior: NoMoreGlow(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ListView(
                    key: const Key('randomList'),
                    controller: randomScrollController,
                    children: [
                      for (int i = 1; i <= state.randomActivities.length; i++)
                        _buildActivity(
                          state.randomActivities[i - 1],
                          i,
                          state.randomStatus,
                        ),
                      if (state.randomStatus == ActivitiesStatus.loading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: CupertinoActivityIndicator(),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (state.error != null) {
            return ErrorScreen(
              retryCallback: () {
                activitiesController.getRandomActivities(howMany: 20);
              },
            );
          }

          return const Expanded(
            child: Center(
              child: CupertinoActivityIndicator(),
            ),
          );
        },
      );
    }
    if (_selectedTab == 1) {
      return BlocBuilder<ActivitiesBloc, ActivitiesState>(
        bloc: _activitiesBloc,
        builder: (context, state) {
          if ((state.filteredStatus == ActivitiesStatus.fetched ||
                  state.filteredStatus == ActivitiesStatus.loading) &&
              state.filteredActivities.isNotEmpty) {
            return Expanded(
              child: ScrollConfiguration(
                behavior: NoMoreGlow(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ListView(
                    key: const Key('filteredList'),
                    controller: filteredScrollController,
                    children: [
                      for (int i = 1; i <= state.filteredActivities.length; i++)
                        _buildActivity(
                          state.filteredActivities[i - 1],
                          i,
                          state.filteredStatus,
                        ),
                      if (state.filteredStatus == ActivitiesStatus.loading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: CupertinoActivityIndicator(),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (state.error != null) {
            if (state.error.message.contains('No activity found')) {
              return const ActivitiesNotFound();
            } else {
              return const ErrorScreen();
            }
          }

          return const Expanded(
            child: Center(
              child: CupertinoActivityIndicator(),
            ),
          );
        },
      );
    }

    // should never reach here
    return const Text('Updated selected pages from bottom navbar');
  }

  Widget _buildActivity(
    Activity? activity,
    int index,
    ActivitiesStatus status,
  ) {
    if (activity != null) {
      return Container(
        height: 230,
        margin: const EdgeInsets.symmetric(vertical: 20),
        child: GestureDetector(
          onTap: status == ActivitiesStatus.loading
              ? null
              : () {
                  activitiesController.selectedActivity(activity: activity);
                  context.pushNamed(AppRoute.detailsView.name);
                },
          child: Stack(
            children: [
              _buildActivityPhotoBG(activity),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: Hero(
                  tag: activity.key + activity.name,
                  child: Material(
                    color: Colors.transparent,
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
                        _buildChips(activity),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox();
  }

  Widget _buildChips(Activity activity) {
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
                activity.accessibility.toStringAsFixed(2),
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

  Widget _buildActivityPhotoBG(Activity activity) {
    return Positioned.fill(
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
    );
  }

  Widget _buildTypeChips(setState) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _buildTypeChip('any', -1, setState),
        for (int i = 0; i < _typeChips.length; i++)
          _buildTypeChip(_typeChips[i], i, setState),
      ],
    );
  }

  Widget _buildTypeChip(String text, int index, setState) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTypeChip = index;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: _selectedTypeChip == index
              ? Colors.teal
              : Colors.white.withOpacity(1),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 3,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: _selectedTypeChip == index ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildParticipantsSlider(setState) {
    return [
      const Text(
        'Participants',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      const SizedBox(height: 10),
      const Divider(
        color: Colors.white,
        height: 3,
      ),
      const SizedBox(height: 10),
      Center(
        child: Text(
          _participants.toString(),
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      const SizedBox(height: 10),
      Slider(
        activeColor: Colors.teal,
        value: _participants.toDouble(),
        min: 1,
        max: 8,
        onChanged: (value) {
          setState(() {
            _participants = value.ceil();
          });
        },
      ),
    ];
  }

  List<Widget> _buildPriceSlider(setState) {
    return [
      const Text(
        'Price',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      const SizedBox(height: 10),
      const Divider(
        color: Colors.white,
        height: 3,
      ),
      const SizedBox(height: 10),
      Center(
        child: Text(
          '${_price.start} - ${_price.end}',
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      const SizedBox(height: 10),
      RangeSlider(
        activeColor: Colors.teal,
        values: _price,
        max: 1.00,
        min: 0.00,
        divisions: 100,
        labels: RangeLabels(
          _price.start.toString(),
          _price.end.toString(),
        ),
        onChanged: (RangeValues values) {
          setState(() {
            _price = values;
          });
        },
      ),
    ];
  }

  List<Widget> _buildAccessibilitySlider(setState) {
    return [
      const Text(
        'Accessibility',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      const SizedBox(height: 10),
      const Divider(
        color: Colors.white,
        height: 3,
      ),
      const SizedBox(height: 10),
      Center(
        child: Text(
          '${_accessibility.start.toStringAsFixed(2)} - ${_accessibility.end.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      const SizedBox(height: 10),
      RangeSlider(
        activeColor: Colors.teal,
        values: _accessibility,
        max: 1.00,
        min: 0.00,
        divisions: 100,
        labels: RangeLabels(
          _accessibility.start.toString(),
          _accessibility.end.toString(),
        ),
        onChanged: (RangeValues values) {
          setState(() {
            _accessibility = values;
          });
        },
      ),
    ];
  }

  Widget _buildApplyFiltersButton(setState, BuildContext dialogContext) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          activitiesController.resetFilteredActivities();
          activitiesController.getFilteredActivities(
            howMany: 10,
            type:
                _selectedTypeChip == -1 ? null : _typeChips[_selectedTypeChip],
            participants: _participants,
            minPrice: _price.start,
            maxPrice: _price.end,
            minAccessibility: _accessibility.start,
            maxAccessibility: _accessibility.end,
          );
          Navigator.pop(dialogContext);
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.teal),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(
              horizontal: 60,
              vertical: 10,
            ),
          ),
        ),
        child: const Text(
          'Apply filters',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
