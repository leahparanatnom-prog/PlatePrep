import 'package:flutter/material.dart';
import '../models/grocery_item_model.dart';
import '../constants/app_colors.dart';

class GroceryItemTile extends StatelessWidget {
  final GroceryItemModel item;
  final ValueChanged<bool?> onToggleBought;
  final VoidCallback onDelete;

  const GroceryItemTile({
    super.key,
    required this.item,
    required this.onToggleBought,
    required this.onDelete,
  });

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'produce':
        return AppColors.produceColor;
      case 'dairy':
        return AppColors.dairyColor;
      case 'pantry':
      default:
        return AppColors.pantryColor;
    }
  }

  Color _getCategoryBg(String category) {
    switch (category.toLowerCase()) {
      case 'produce':
        return AppColors.produceBg;
      case 'dairy':
        return AppColors.dairyBg;
      case 'pantry':
      default:
        return AppColors.pantryBg;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'produce':
        return Icons.eco_rounded;
      case 'dairy':
        return Icons.local_drink_rounded;
      case 'pantry':
      default:
        return Icons.inventory_2_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _getCategoryColor(item.category);
    final catBg = _getCategoryBg(item.category);
    final catIcon = _getCategoryIcon(item.category);

    return Dismissible(
      key: Key(item.itemId),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 22),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: item.isBought ? const Color(0xFFF8F9F8) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: item.isBought ? AppColors.divider : AppColors.border,
            width: 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => onToggleBought(!item.isBought),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Custom Checkbox
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: item.isBought ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: item.isBought ? AppColors.primary : AppColors.textMuted,
                      width: 1.8,
                    ),
                  ),
                  child: item.isBought
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
                const SizedBox(width: 12),

                // Category Icon Capsule
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: catBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(catIcon, color: catColor, size: 16),
                ),
                const SizedBox(width: 12),

                // Item Name with animated Strikethrough effect
                Expanded(
                  child: Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: item.isBought ? FontWeight.w400 : FontWeight.w600,
                      color: item.isBought ? AppColors.textMuted : AppColors.textDark,
                      decoration: item.isBought
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: AppColors.textMuted,
                      decorationThickness: 1.8,
                    ),
                  ),
                ),

                // Category Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: catBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.category,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: catColor,
                    ),
                  ),
                ),

                const SizedBox(width: 6),

                // Quick Delete button
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
                  splashRadius: 18,
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

