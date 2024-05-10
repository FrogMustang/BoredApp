import 'package:bored_app/application.dart';
import 'package:bored_app/bloc/activity/activities_bloc.dart';
import 'package:bored_app/constants.dart';
import 'package:bored_app/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final ActivitiesBloc _activitiesBloc = getIt<ActivitiesBloc>();

class FilterActivitiesButton extends StatelessWidget {
  const FilterActivitiesButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.filter_list_rounded,
        size: 24,
      ),
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (context) {
            return BlocProvider.value(
              value: getIt.get<ActivitiesBloc>(),
              child: BlocBuilder<ActivitiesBloc, ActivitiesState>(
                  builder: (context, state) {
                final ActivityFilters filters = state.filters!;

                return AlertDialog(
                  backgroundColor: Colors.black.withOpacity(0.7),
                  content: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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

                          /// ACTIVITY TYPE CHIPS
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: ActivityCategory.values
                                .map(
                                  (ActivityCategory category) => _CategoryChip(
                                    category: category,
                                    filters: state.filters!,
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 30),

                          /// PRICE SLIDER
                          _PriceSlider(
                            filters: filters,
                          ),

                          const SizedBox(height: 30),
                          _ParticipantsSlider(
                            filters: filters,
                          ),
                          const SizedBox(height: 30),
                          _AccessibilitySlider(
                            filters: filters,
                          ),
                          const SizedBox(height: 30),
                          const _ApplyFiltersButton(),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        );
      },
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.filters,
  });

  final ActivityCategory category;
  final ActivityFilters filters;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _activitiesBloc.add(
          UpdateActivityFilters(
            filters: filters.copyWith(
              activityCategory: category,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: filters.activityCategory == category
              ? Colors.teal
              : Colors.white.withOpacity(1),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 3,
        ),
        child: Text(
          category.name,
          style: TextStyle(
            color: filters.activityCategory == category
                ? Colors.white
                : Colors.black,
          ),
        ),
      ),
    );
  }
}

class _PriceSlider extends StatelessWidget {
  const _PriceSlider({required this.filters});

  final ActivityFilters filters;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
            '${filters.minPrice} - ${filters.maxPrice}',
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 10),
        RangeSlider(
          activeColor: Colors.teal,
          values: RangeValues(
            filters.minPrice,
            filters.maxPrice,
          ),
          max: 1.00,
          min: 0.00,
          divisions: 100,
          labels: RangeLabels(
            filters.minPrice.toString(),
            filters.maxPrice.toString(),
          ),
          onChanged: (RangeValues values) {
            _activitiesBloc.add(
              UpdateActivityFilters(
                filters: filters.copyWith(
                  minPrice: values.start,
                  maxPrice: values.end,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ParticipantsSlider extends StatelessWidget {
  const _ParticipantsSlider({required this.filters});

  final ActivityFilters filters;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
            (filters.participants ?? 1).toString(),
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Slider(
          activeColor: Colors.teal,
          value: filters.participants?.toDouble() ?? 1,
          min: 1,
          max: 8,
          onChanged: (value) {
            _activitiesBloc.add(
              UpdateActivityFilters(
                filters: filters.copyWith(
                  participants: value.toInt(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _AccessibilitySlider extends StatelessWidget {
  const _AccessibilitySlider({required this.filters});

  final ActivityFilters filters;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
            '${filters.minAccessibility.toStringAsFixed(2)} - ${filters.maxAccessibility.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 10),
        RangeSlider(
          activeColor: Colors.teal,
          values: RangeValues(
            filters.minAccessibility,
            filters.maxAccessibility,
          ),
          max: 1.00,
          min: 0.00,
          divisions: 100,
          labels: RangeLabels(
            filters.minAccessibility.toString(),
            filters.maxAccessibility.toString(),
          ),
          onChanged: (RangeValues values) {
            _activitiesBloc.add(
              UpdateActivityFilters(
                filters: filters.copyWith(
                  minAccessibility: values.start,
                  maxAccessibility: values.end,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ApplyFiltersButton extends StatelessWidget {
  const _ApplyFiltersButton();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // reset the filters and the filtered activities
          _activitiesBloc.add(ResetFilteredActivities());

          // and fetch new ones
          _activitiesBloc.add(
            GetFilteredActivities(
              howMany: Constants.howManyFilteredActivities,
              filters: _activitiesBloc.state.filters,
            ),
          );

          Navigator.pop(context);
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
