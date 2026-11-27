import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/meal_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/date_formatter.dart';
import '../../utils/ui_feedback.dart';
import '../../widgets/calorie_progress_card.dart';
import '../../widgets/meal_card.dart';
import '../../widgets/empty_state.dart';
import '../meals/add_edit_meal_sheet.dart';

class DashboardScreen extends StatelessWidget {
  final String userId;
  final UserModel? userProfile;
  final FirestoreService firestoreService;
  final VoidCallback onNavigateToMeals;
  final VoidCallback onNavigateToGrocery;

  const DashboardScreen({
    super.key,
    required this.userId,
    required this.userProfile,
    required this.firestoreService,
    required this.onNavigateToMeals,
    required this.onNavigateToGrocery,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final chefName = userProfile?.name ?? 'Chef';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<List<MealModel>>(
          stream: firestoreService.getTodayMealsStream(userId),
          builder: (context, snapshot) {
            final todayMeals = snapshot.data ?? [];
            final calorieTarget = userProfile?.calorieTarget ?? 2000;

            return CustomScrollView(
              slivers: [
                // Top App Bar / Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Current Date
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormatter.formatFullDate(now).toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.bolt_rounded, size: 14, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${todayMeals.where((m) => m.isPrepped).length}/${todayMeals.length} Done',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Greeting
                        Text(
                          'Welcome back, $chefName!',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Plan, prep, and eat smart on your student schedule.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Overview Widget: Progress & Macro/Calorie Target
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: CalorieProgressCard(
                      todayMeals: todayMeals,
                      calorieTarget: calorieTarget,
                    ),
                  ),
                ),

                // Quick Action Banner: "Add Today's Meal"
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, Color(0xFF3B6748)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.add_task_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Add Today's Meal",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  "Track breakfast, lunch, or dinner",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                            onPressed: () {
                              AddEditMealSheet.show(
                                context,
                                userId: userId,
                                firestoreService: firestoreService,
                                defaultDate: DateTime.now(),
                              );
                            },
                            child: const Text(
                              '+ Add',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Section Header: Today's Meal Plan Summary
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Today's Meal Plan",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        TextButton(
                          onPressed: onNavigateToMeals,
                          child: const Row(
                            children: [
                              Text(
                                'View All Meals',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.primary),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Meal List or Empty State
                if (snapshot.connectionState == ConnectionState.waiting) ...[
                  const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                    ),
                  ),
                ] else if (todayMeals.isEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: EmptyStateWidget(
                        icon: Icons.flatware_rounded,
                        title: 'No meals scheduled for today',
                        message: 'Tap "+ Add Today\'s Meal" above or view all recipes to fill your daily menu!',
                        buttonText: 'Plan a Meal',
                        onButtonPressed: () {
                          AddEditMealSheet.show(
                            context,
                            userId: userId,
                            firestoreService: firestoreService,
                            defaultDate: DateTime.now(),
                          );
                        },
                      ),
                    ),
                  ),
                ] else ...[
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final meal = todayMeals[index];
                          return MealCard(
                            meal: meal,
                            onTogglePrepped: (val) async {
                              final newPrepped = val ?? !meal.isPrepped;
                              await firestoreService.toggleMealPrepped(
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
                                userId: userId,
                                firestoreService: firestoreService,
                                existingMeal: meal,
                              );
                            },
                            onDelete: () async {
                              await firestoreService.deleteMeal(meal.mealId);
                              if (context.mounted) {
                                UIFeedback.showInfo(context, 'Meal removed');
                              }
                            },
                          );
                        },
                        childCount: todayMeals.length,
                      ),
                    ),
                  ),
                ],

                // Student Kitchen Quick Cards
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kitchen Shortcuts',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            // Grocery shortcut
                            Expanded(
                              child: InkWell(
                                onTap: onNavigateToGrocery,
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.shopping_cart_checkout_rounded, color: AppColors.primary, size: 26),
                                      SizedBox(height: 10),
                                      Text(
                                        'Grocery List',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Auto-extracted items',
                                        style: TextStyle(fontSize: 11.5, color: AppColors.textMedium),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Timer shortcut
                            Expanded(
                              child: InkWell(
                                onTap: onNavigateToGrocery,
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.timer_outlined, color: AppColors.accent, size: 26),
                                      SizedBox(height: 10),
                                      Text(
                                        'Cooking Timer',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Countdown presets',
                                        style: TextStyle(fontSize: 11.5, color: AppColors.textMedium),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

