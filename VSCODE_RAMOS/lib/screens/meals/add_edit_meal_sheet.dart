import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/meal_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/ui_feedback.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddEditMealSheet extends StatefulWidget {
  final String userId;
  final FirestoreService firestoreService;
  final MealModel? existingMeal;
  final DateTime? defaultDate;

  const AddEditMealSheet({
    super.key,
    required this.userId,
    required this.firestoreService,
    this.existingMeal,
    this.defaultDate,
  });

  static Future<void> show(
    BuildContext context, {
    required String userId,
    required FirestoreService firestoreService,
    MealModel? existingMeal,
    DateTime? defaultDate,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddEditMealSheet(
        userId: userId,
        firestoreService: firestoreService,
        existingMeal: existingMeal,
        defaultDate: defaultDate,
      ),
    );
  }

  @override
  State<AddEditMealSheet> createState() => _AddEditMealSheetState();
}

class _AddEditMealSheetState extends State<AddEditMealSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _prepTimeController;
  late TextEditingController _ingredientsController;

  late String _selectedCategory;
  late DateTime _selectedDate;
  bool _isLoading = false;

  final List<String> _categories = ['Breakfast', 'Lunch', 'Dinner', 'Snacks'];

  @override
  void initState() {
    super.initState();
    final meal = widget.existingMeal;
    _titleController = TextEditingController(text: meal?.title ?? '');
    _prepTimeController = TextEditingController(
      text: meal != null ? meal.prepTimeMinutes.toString() : '20',
    );
    _ingredientsController = TextEditingController(
      text: meal != null ? meal.ingredients.join(', ') : '',
    );
    _selectedCategory = meal?.category ?? 'Dinner';
    _selectedDate = meal?.scheduledDate ?? widget.defaultDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _prepTimeController.dispose();
    _ingredientsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveMeal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final rawIngredients = _ingredientsController.text
          .split(',')
          .map((i) => i.trim())
          .where((i) => i.isNotEmpty)
          .toList();

      final prepTime = int.tryParse(_prepTimeController.text.trim()) ?? 20;

      if (widget.existingMeal == null) {
        // Create new
        final newMeal = MealModel(
          mealId: '',
          userId: widget.userId,
          title: _titleController.text.trim(),
          category: _selectedCategory,
          ingredients: rawIngredients,
          prepTimeMinutes: prepTime,
          scheduledDate: _selectedDate,
          isPrepped: false,
        );
        await widget.firestoreService.addMeal(newMeal);
        if (mounted) {
          Navigator.of(context).pop();
          UIFeedback.showSuccess(context, 'Meal added to your plan!');
        }
      } else {
        // Update existing
        final updatedMeal = widget.existingMeal!.copyWith(
          title: _titleController.text.trim(),
          category: _selectedCategory,
          ingredients: rawIngredients,
          prepTimeMinutes: prepTime,
          scheduledDate: _selectedDate,
        );
        await widget.firestoreService.updateMeal(updatedMeal);
        if (mounted) {
          Navigator.of(context).pop();
          UIFeedback.showSuccess(context, 'Meal updated successfully!');
        }
      }
    } catch (e) {
      if (mounted) {
        UIFeedback.showError(context, 'Failed to save meal: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingMeal != null;
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: 24 + keyboardPadding,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sheet Handle bar
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Meal' : 'Add New Meal',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMedium),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Title Field
              CustomTextField(
                controller: _titleController,
                label: 'Meal Title',
                hint: 'e.g. Garlic Butter Chicken & Rice',
                prefixIcon: Icons.restaurant_menu_rounded,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a meal title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category Selector
              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    selectedColor: AppColors.primaryLight,
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: 1.2,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.textDark,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 13,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategory = category);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Prep Time and Scheduled Date in Row
              Row(
                children: [
                  // Prep Time
                  Expanded(
                    flex: 1,
                    child: CustomTextField(
                      controller: _prepTimeController,
                      label: 'Prep (mins)',
                      hint: '25',
                      prefixIcon: Icons.timer_outlined,
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Required';
                        if (int.tryParse(val) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Scheduled Date Picker Button
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Scheduled Date',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 7),
                        InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            height: 52,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border, width: 1.2),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_rounded,
                                  color: AppColors.textMedium,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    DateFormatter.isToday(_selectedDate)
                                        ? 'Today'
                                        : DateFormatter.formatShortDate(_selectedDate),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Ingredients (Comma-separated)
              CustomTextField(
                controller: _ingredientsController,
                label: 'Ingredients (comma-separated)',
                hint: 'Chicken breast, Garlic, Rice, Olive oil, Salt',
                prefixIcon: Icons.shopping_basket_outlined,
                maxLines: 2,
              ),
              const SizedBox(height: 6),
              const Text(
                'Tip: Adding ingredients here will automatically generate your Grocery List!',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 24),

              // Save Action Button
              CustomButton(
                text: isEditing ? 'Update Meal' : 'Save to Meal Plan',
                icon: isEditing ? Icons.check_circle_outline : Icons.add_rounded,
                isLoading: _isLoading,
                onPressed: _saveMeal,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

