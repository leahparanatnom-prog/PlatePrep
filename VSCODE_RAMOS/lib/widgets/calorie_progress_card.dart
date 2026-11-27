import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/meal_model.dart';

class CalorieProgressCard extends StatelessWidget {
  final List<MealModel> todayMeals;
  final int calorieTarget;

  const CalorieProgressCard({
    super.key,
    required this.todayMeals,
    this.calorieTarget = 2000,
  });

  @override
  Widget build(BuildContext context) {
    final totalMeals = todayMeals.length;
    final preppedMeals = todayMeals.where((m) => m.isPrepped).length;
    final double prepRatio = totalMeals > 0 ? (preppedMeals / totalMeals) : 0.0;
    final int percentage = (prepRatio * 100).toInt();

    // Approximate calories prepped based on ratio
    final int currentCalories = totalMeals > 0
        ? ((preppedMeals / totalMeals) * calorieTarget).toInt()
        : 0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.restaurant_menu_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Prep Progress',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        'Target vs. Prepped Meals',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Percentage Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: percentage == 100
                      ? AppColors.successLight
                      : AppColors.accentLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: percentage == 100
                        ? AppColors.success
                        : AppColors.accent,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Progress Bar with custom styling
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 10,
              child: LinearProgressIndicator(
                value: prepRatio,
                backgroundColor: AppColors.cardSurfaceAlt,
                valueColor: AlwaysStoppedAnimation<Color>(
                  percentage == 100 ? AppColors.success : AppColors.primary,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Progress Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Meals Prepped Counter
              Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$preppedMeals of $totalMeals meals prepped today',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),

              // Calorie Goal Indicator
              Text(
                '$currentCalories / $calorieTarget kcal',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

