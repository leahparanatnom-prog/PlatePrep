class IngredientCategorizer {
  static const List<String> produceKeywords = [
    'apple', 'banana', 'orange', 'lemon', 'lime', 'avocado', 'tomato', 'onion',
    'garlic', 'potato', 'carrot', 'spinach', 'lettuce', 'kale', 'broccoli',
    'cucumber', 'pepper', 'bell pepper', 'chili', 'cilantro', 'parsley',
    'basil', 'mushroom', 'ginger', 'scallion', 'green onion', 'celery',
    'cabbage', 'zucchini', 'berries', 'strawberry', 'blueberry', 'herb', 'fruit', 'vegetable'
  ];

  static const List<String> dairyKeywords = [
    'milk', 'cheese', 'cheddar', 'mozzarella', 'parmesan', 'butter', 'cream',
    'yogurt', 'egg', 'eggs', 'heavy cream', 'sour cream', 'curd', 'ghee',
    'cream cheese', 'ricotta', 'mayo', 'mayonnaise'
  ];

  /// Categorize ingredient text into 'Produce', 'Dairy', or 'Pantry'
  static String categorize(String ingredientName) {
    final lower = ingredientName.toLowerCase().trim();

    for (final word in produceKeywords) {
      if (lower.contains(word)) {
        return 'Produce';
      }
    }

    for (final word in dairyKeywords) {
      if (lower.contains(word)) {
        return 'Dairy';
      }
    }

    // Default student pantry category
    return 'Pantry';
  }
}

