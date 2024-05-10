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
    final DraggableScrollableController sheetController =
        DraggableScrollableController();

    return IconButton(
      icon: const Icon(
        Icons.filter_list_rounded,
        size: 24,
      ),
      onPressed: () async {
        // Not the best UX, but it's meant to showcase some UI skills
        showBottomSheet(
          context: context,
          enableDrag: false,
          backgroundColor: Colors.transparent,
          builder: (context) {
            return BlocProvider.value(
              value: getIt<ActivitiesBloc>(),
              child: DraggableScrollableSheet(
                expand: false,
                maxChildSize: 0.9,
                minChildSize: 0.3,
                initialChildSize: 0.3,
                shouldCloseOnMinExtent: false,
                controller: sheetController,
                builder: (context, scrollController) {
                  final size = MediaQuery.sizeOf(context);

                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // DRAG HANDLE
                        ScrollConfiguration(
                          behavior: NoMoreGlow(),
                          child: SizedBox(
                            height: 20,
                            width: size.width,
                            child: SingleChildScrollView(
                              controller: scrollController,
                              child: Center(
                                child: Container(
                                  height: 3,
                                  width: 70,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(200),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        Flexible(
                          child: _SheetContent(
                            sheetController: sheetController,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _SheetContent extends StatefulWidget {
  const _SheetContent({
    super.key,
    required this.sheetController,
  });

  final DraggableScrollableController sheetController;

  @override
  State<_SheetContent> createState() => _SheetContentState();
}

class _SheetContentState extends State<_SheetContent> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivitiesBloc, ActivitiesState>(
        builder: (context, state) {
      final filters = state.filters!;

      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      widget.sheetController.animateTo(
                        isExpanded
                            ? Constants.minFiltersSheetSize
                            : Constants.maxFiltersSheetSize,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );

                      isExpanded = !isExpanded;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Icon(
                      isExpanded ? Icons.fullscreen_exit : Icons.fullscreen,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

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
                      filters: filters,
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

            const SizedBox(height: 30),
          ],
        ),
      );
    });
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
