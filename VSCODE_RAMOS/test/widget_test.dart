import 'package:flutter_test/flutter_test.dart';
import 'package:plateprep/models/meal_model.dart';
import 'package:plateprep/models/grocery_item_model.dart';
import 'package:plateprep/utils/ingredient_categorizer.dart';
import 'package:plateprep/utils/date_formatter.dart';

void main() {
  group('PlatePrep Logic & Model Tests', () {
    test('IngredientCategorizer correctly classifies ingredients', () {
      expect(IngredientCategorizer.categorize('fresh spinach'), 'Produce');
      expect(IngredientCategorizer.categorize('cheddar cheese'), 'Dairy');
      expect(IngredientCategorizer.categorize('whole milk'), 'Dairy');
      expect(IngredientCategorizer.categorize('olive oil'), 'Pantry');
      expect(IngredientCategorizer.categorize('jasmine rice'), 'Pantry');
    });

    test('MealModel serialization and deserialization', () {
      final now = DateTime.now();
      final meal = MealModel(
        mealId: 'meal-001',
        userId: 'user-123',
        title: 'Chicken & Veggie Rice Bowl',
        category: 'Dinner',
        ingredients: ['chicken', 'rice', 'broccoli'],
        prepTimeMinutes: 25,
        scheduledDate: now,
        isPrepped: false,
      );

      final map = meal.toMap();
      expect(map['title'], 'Chicken & Veggie Rice Bowl');
      expect(map['prepTimeMinutes'], 25);
      expect(map['ingredients'].length, 3);

      final copy = meal.copyWith(isPrepped: true);
      expect(copy.isPrepped, true);
      expect(copy.title, 'Chicken & Veggie Rice Bowl');
    });

    test('GroceryItemModel serialization and toggle', () {
      final item = GroceryItemModel(
        itemId: 'item-101',
        userId: 'user-123',
        name: 'Avocado',
        category: 'Produce',
        isBought: false,
      );

      expect(item.name, 'Avocado');
      expect(item.category, 'Produce');

      final boughtItem = item.copyWith(isBought: true);
      expect(boughtItem.isBought, true);
    });

    test('DateFormatter formats timer seconds correctly', () {
      expect(DateFormatter.formatTimerDuration(1500), '25:00');
      expect(DateFormatter.formatTimerDuration(90), '01:30');
      expect(DateFormatter.formatTimerDuration(5), '00:05');
    });
  });
}

