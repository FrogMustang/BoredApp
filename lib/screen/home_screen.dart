import 'package:bored_app/application.dart';
import 'package:bored_app/bloc/activity/activities_bloc.dart';
import 'package:bored_app/exceptions/activities_error.dart';
import 'package:bored_app/screen/filtered_activities/filter_activities_button.dart';
import 'package:bored_app/screen/filtered_activities/filtered_activities.dart';
import 'package:bored_app/screen/random_activities/random_activities.dart';
import 'package:bored_app/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;
  final List<String> _tabTitles = ['Activities', 'Help me find an activity'];

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
                        ? const FilterActivitiesButton()
                        : const SizedBox(height: 50),
                  ],
                ),
              ),
              Expanded(child: () {
                switch (_selectedTab) {
                  case 0:
                    return const RandomActivitiesScreen();
                  case 1:
                    return const FilteredActivitiesScreen();
                  default:
                    return const RandomActivitiesScreen();
                }
              }()),
            ],
          ),
        ),
      ),
    );
  }
}
