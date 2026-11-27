import 'package:flutter/material.dart';
import '../models/meal_model.dart';
import '../constants/app_colors.dart';
import '../utils/date_formatter.dart';

class MealCard extends StatelessWidget {
  final MealModel meal;
  final ValueChanged<bool?> onTogglePrepped;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MealCard({
    super.key,
    required this.meal,
    required this.onTogglePrepped,
    required this.onEdit,
    required this.onDelete,
  });

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'breakfast':
        return const Color(0xFFF59E0B); // Amber
      case 'lunch':
        return AppColors.accent; // Warm Orange
      case 'dinner':
        return AppColors.primary; // Sage Green
      case 'snack':
      case 'snacks':
        return const Color(0xFF8B5CF6); // Purple
      default:
        return AppColors.textMedium;
    }
  }

  Color _getCategoryBg(String category) {
    switch (category.toLowerCase()) {
      case 'breakfast':
        return const Color(0xFFFEF3C7);
      case 'lunch':
        return AppColors.accentLight;
      case 'dinner':
        return AppColors.primaryLight;
      case 'snack':
      case 'snacks':
        return const Color(0xFFEDE9FE);
      default:
        return AppColors.cardSurfaceAlt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _getCategoryColor(meal.category);
    final catBg = _getCategoryBg(meal.category);

    return Dismissible(
      key: Key(meal.mealId),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete_outline, color: Colors.white, size: 24),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: const Text('Delete Meal?'),
            content: Text('Are you sure you want to remove "${meal.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel', style: TextStyle(color: AppColors.textMedium)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Delete', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: meal.isPrepped ? AppColors.primary.withOpacity(0.3) : AppColors.border,
            width: meal.isPrepped ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Prepped Checkbox
                GestureDetector(
                  onTap: () => onTogglePrepped(!meal.isPrepped),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: meal.isPrepped ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: meal.isPrepped ? AppColors.primary : AppColors.textMuted,
                        width: 2,
                      ),
                    ),
                    child: meal.isPrepped
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                ),
                const SizedBox(width: 14),

                // Meal Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Category Chip
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: catBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              meal.category.toUpperCase(),
                              style: TextStyle(
                                color: catColor,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Prep Time Badge
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.schedule_rounded,
                                size: 14,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${meal.prepTimeMinutes} min',
                                style: const TextStyle(
                                  color: AppColors.textMedium,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          if (meal.isPrepped) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.successLight,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'PREPPED',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Title
                      Text(
                        meal.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: meal.isPrepped ? AppColors.textMedium : AppColors.textDark,
                          decoration: meal.isPrepped ? TextDecoration.lineThrough : null,
                        ),
                      ),

                      // Ingredients count & preview
                      if (meal.ingredients.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${meal.ingredients.length} items: ${meal.ingredients.take(3).join(', ')}${meal.ingredients.length > 3 ? '...' : ''}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // Action Menu
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: AppColors.textMedium),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18, color: AppColors.textDark),
                          SizedBox(width: 10),
                          Text('Edit Meal'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                          SizedBox(width: 10),
                          Text('Delete', style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

