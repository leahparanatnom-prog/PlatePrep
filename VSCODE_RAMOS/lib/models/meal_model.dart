import 'package:cloud_firestore/cloud_firestore.dart';

class MealModel {
  final String mealId;
  final String userId;
  final String title;
  final String category; // "Breakfast", "Lunch", "Dinner", "Snack"
  final List<String> ingredients;
  final int prepTimeMinutes;
  final DateTime scheduledDate;
  final bool isPrepped;

  MealModel({
    required this.mealId,
    required this.userId,
    required this.title,
    required this.category,
    required this.ingredients,
    required this.prepTimeMinutes,
    required this.scheduledDate,
    this.isPrepped = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'mealId': mealId,
      'userId': userId,
      'title': title,
      'category': category,
      'ingredients': ingredients,
      'prepTimeMinutes': prepTimeMinutes,
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'isPrepped': isPrepped,
    };
  }

  factory MealModel.fromMap(Map<String, dynamic> map, {String? id}) {
    DateTime parsedDate;
    if (map['scheduledDate'] is Timestamp) {
      parsedDate = (map['scheduledDate'] as Timestamp).toDate();
    } else if (map['scheduledDate'] is String) {
      parsedDate = DateTime.tryParse(map['scheduledDate']) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    List<String> parsedIngredients = [];
    if (map['ingredients'] is List) {
      parsedIngredients = (map['ingredients'] as List)
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    return MealModel(
      mealId: id ?? map['mealId'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? 'Untitled Meal',
      category: map['category'] ?? 'Dinner',
      ingredients: parsedIngredients,
      prepTimeMinutes: (map['prepTimeMinutes'] is num)
          ? (map['prepTimeMinutes'] as num).toInt()
          : 20,
      scheduledDate: parsedDate,
      isPrepped: map['isPrepped'] ?? false,
    );
  }

  factory MealModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return MealModel.fromMap(data, id: doc.id);
  }

  MealModel copyWith({
    String? mealId,
    String? userId,
    String? title,
    String? category,
    List<String>? ingredients,
    int? prepTimeMinutes,
    DateTime? scheduledDate,
    bool? isPrepped,
  }) {
    return MealModel(
      mealId: mealId ?? this.mealId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      category: category ?? this.category,
      ingredients: ingredients ?? this.ingredients,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      isPrepped: isPrepped ?? this.isPrepped,
    );
  }
}

