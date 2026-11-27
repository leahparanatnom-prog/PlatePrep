import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/meal_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/meal_card.dart';
import '../../widgets/empty_state.dart';
import '../../utils/ui_feedback.dart';
import 'add_edit_meal_sheet.dart';

class MealManagerScreen extends StatefulWidget {
  final String userId;
  final FirestoreService firestoreService;

  const MealManagerScreen({
    super.key,
    required this.userId,
    required this.firestoreService,
  });

  @override
  State<MealManagerScreen> createState() => _MealManagerScreenState();
}

class _MealManagerScreenState extends State<MealManagerScreen> {
  String _selectedCategory = 'All';

  final List<String> _filters = [
    'All',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snacks',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Meal & Recipe Manager',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 28),
            tooltip: 'Add Meal',
            onPressed: () {
              AddEditMealSheet.show(
                context,
                userId: widget.userId,
                firestoreService: widget.firestoreService,
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Filter Chips
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _filters[index];
                final isSelected = _selectedCategory == category;

                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: 1,
                  ),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textDark,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 13,
                  ),
                  showCheckmark: false,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedCategory = category);
                    }
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Real-time Firestore Stream of meals
          Expanded(
            child: StreamBuilder<List<MealModel>>(
              stream: widget.firestoreService.getMealsStream(widget.userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading meals: ${snapshot.error}'),
                  );
                }

                final allMeals = snapshot.data ?? [];

                // Filter by category
                final filteredMeals = _selectedCategory == 'All'
                    ? allMeals
                    : allMeals.where((m) {
                        if (_selectedCategory == 'Snacks') {
                          return m.category.toLowerCase().contains('snack');
                        }
                        return m.category.toLowerCase() == _selectedCategory.toLowerCase();
                      }).toList();

                if (filteredMeals.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.dinner_dining_rounded,
                    title: _selectedCategory == 'All'
                        ? 'No meals planned yet'
                        : 'No ${_selectedCategory.toLowerCase()} meals found',
                    message: _selectedCategory == 'All'
                        ? 'Organize your weekly diet by adding your favorite breakfasts, lunches, and dinners.'
                        : 'Tap the button below to add your first ${_selectedCategory.toLowerCase()} recipe!',
                    buttonText: 'Add a Meal',
                    onButtonPressed: () {
                      AddEditMealSheet.show(
                        context,
                        userId: widget.userId,
                        firestoreService: widget.firestoreService,
                      );
                    },
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filteredMeals.length,
                  itemBuilder: (context, index) {
                    final meal = filteredMeals[index];

                    return MealCard(
                      meal: meal,
                      onTogglePrepped: (val) async {
                        final newPrepped = val ?? !meal.isPrepped;
                        await widget.firestoreService.toggleMealPrepped(
                          meal.mealId,
                          newPrepped,
                        );
                        if (context.mounted) {
                          UIFeedback.showSuccess(
                            context,
                            newPrepped
                                ? '"${meal.title}" marked as Prepped!'
                                : '"${meal.title}" marked as Unprepped',
                          );
                        }
                      },
                      onEdit: () {
                        AddEditMealSheet.show(
                          context,
                          userId: widget.userId,
                          firestoreService: widget.firestoreService,
                          existingMeal: meal,
                        );
                      },
                      onDelete: () async {
                        await widget.firestoreService.deleteMeal(meal.mealId);
                        if (context.mounted) {
                          UIFeedback.showInfo(
                            context,
                            'Meal "${meal.title}" deleted',
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        onPressed: () {
          AddEditMealSheet.show(
            context,
            userId: widget.userId,
            firestoreService: widget.firestoreService,
          );
        },
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}

