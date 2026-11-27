import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/grocery_item_model.dart';
import '../../models/meal_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/grocery_item_tile.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/ui_feedback.dart';

class GrocerySection extends StatefulWidget {
  final String userId;
  final FirestoreService firestoreService;

  const GrocerySection({
    super.key,
    required this.userId,
    required this.firestoreService,
  });

  @override
  State<GrocerySection> createState() => _GrocerySectionState();
}

class _GrocerySectionState extends State<GrocerySection> {
  String _selectedCategory = 'All';
  bool _isGenerating = false;

  final List<String> _categories = ['All', 'Produce', 'Dairy', 'Pantry'];

  Future<void> _generateList(List<MealModel> meals) async {
    if (meals.isEmpty) {
      UIFeedback.showInfo(context, 'No planned meals found. Add some meals first!');
      return;
    }

    setState(() => _isGenerating = true);
    try {
      final addedCount = await widget.firestoreService.generateGroceryListFromMeals(
        userId: widget.userId,
        meals: meals,
      );

      if (mounted) {
        if (addedCount > 0) {
          UIFeedback.showSuccess(
            context,
            'Generated $addedCount grocery items from your meal plan!',
          );
        } else {
          UIFeedback.showInfo(
            context,
            'All ingredients are already in your grocery list!',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        UIFeedback.showError(context, 'Error generating list: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  void _showAddCustomItemDialog() {
    final nameController = TextEditingController();
    String selectedCat = 'Produce';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Add Grocery Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: nameController,
                label: 'Item Name',
                hint: 'e.g. Greek Yogurt, Oats, Spinach',
                prefixIcon: Icons.shopping_basket_outlined,
              ),
              const SizedBox(height: 16),
              const Text(
                'Category',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedCat,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: ['Produce', 'Dairy', 'Pantry'].map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedCat = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textMedium)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  final newItem = GroceryItemModel(
                    itemId: '',
                    userId: widget.userId,
                    name: name,
                    category: selectedCat,
                    isBought: false,
                  );
                  await widget.firestoreService.addGroceryItem(newItem);
                  if (context.mounted) {
                    Navigator.of(ctx).pop();
                    UIFeedback.showSuccess(context, 'Added "$name" to groceries');
                  }
                }
              },
              child: const Text('Add Item', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MealModel>>(
      stream: widget.firestoreService.getMealsStream(widget.userId),
      builder: (context, mealsSnapshot) {
        final meals = mealsSnapshot.data ?? [];

        return StreamBuilder<List<GroceryItemModel>>(
          stream: widget.firestoreService.getGroceryItemsStream(widget.userId),
          builder: (context, grocerySnapshot) {
            if (grocerySnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            final items = grocerySnapshot.data ?? [];
            final boughtCount = items.where((i) => i.isBought).length;

            final filteredItems = _selectedCategory == 'All'
                ? items
                : items.where((i) => i.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();

            return Column(
              children: [
                // Section Header / Quick Actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      // Generate Button
                      Expanded(
                        child: CustomButton(
                          text: 'Generate from Meals',
                          icon: Icons.auto_awesome_rounded,
                          variant: ButtonVariant.primary,
                          height: 48,
                          isLoading: _isGenerating,
                          onPressed: () => _generateList(meals),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Manual Add Item Button
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.accentLight,
                          foregroundColor: AppColors.accent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.all(12),
                        ),
                        icon: const Icon(Icons.add_rounded, size: 24),
                        tooltip: 'Add Custom Item',
                        onPressed: _showAddCustomItemDialog,
                      ),

                      if (boughtCount > 0) ...[
                        const SizedBox(width: 8),
                        IconButton.outlined(
                          style: IconButton.styleFrom(
                            side: const BorderSide(color: AppColors.divider),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.all(12),
                          ),
                          icon: const Icon(Icons.cleaning_services_rounded, size: 20, color: AppColors.textMedium),
                          tooltip: 'Clear Purchased Items',
                          onPressed: () async {
                            await widget.firestoreService.clearBoughtGroceryItems(widget.userId);
                            if (context.mounted) {
                              UIFeedback.showInfo(context, 'Cleared $boughtCount purchased items');
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                ),

                // Category Filter Pills
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = _selectedCategory == cat;

                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor: AppColors.primaryLight,
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.primary : AppColors.textDark,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 12.5,
                        ),
                        showCheckmark: false,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedCategory = cat);
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 6),

                // Grocery Items List
                Expanded(
                  child: filteredItems.isEmpty
                      ? EmptyStateWidget(
                          icon: Icons.shopping_basket_outlined,
                          title: items.isEmpty
                              ? 'Your grocery list is empty'
                              : 'No $_selectedCategory items',
                          message: items.isEmpty
                              ? 'Tap "Generate from Meals" to automatically create your shopping checklist from planned recipes!'
                              : 'Tap "+" above to add an item to this category.',
                          buttonText: items.isEmpty ? 'Generate Now' : null,
                          onButtonPressed: items.isEmpty ? () => _generateList(meals) : null,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];

                            return GroceryItemTile(
                              item: item,
                              onToggleBought: (val) async {
                                final newBought = val ?? !item.isBought;
                                await widget.firestoreService.toggleGroceryItemBought(
                                  item.itemId,
                                  newBought,
                                );
                                if (context.mounted) {
                                  UIFeedback.showSuccess(
                                    context,
                                    newBought
                                        ? 'Marked "${item.name}" as bought!'
                                        : 'Marked "${item.name}" as pending',
                                  );
                                }
                              },
                              onDelete: () async {
                                await widget.firestoreService.deleteGroceryItem(item.itemId);
                                if (context.mounted) {
                                  UIFeedback.showInfo(context, 'Removed "${item.name}"');
                                }
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

