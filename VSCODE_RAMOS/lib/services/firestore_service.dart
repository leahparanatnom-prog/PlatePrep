import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/meal_model.dart';
import '../models/grocery_item_model.dart';
import '../models/user_model.dart';
import '../utils/ingredient_categorizer.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Collection references
  CollectionReference get _usersCol => _firestore.collection('users');
  CollectionReference get _mealsCol => _firestore.collection('meals');
  CollectionReference get _groceryCol => _firestore.collection('groceryItems');

  // ==========================================
  // MEALS - REAL-TIME STREAMS & CRUD
  // ==========================================

  /// Stream all meals for a specific userId ordered by scheduled date
  Stream<List<MealModel>> getMealsStream(String userId) {
    if (userId.isEmpty) return Stream.value([]);

    return _mealsCol
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => MealModel.fromFirestore(doc))
              .toList();
          // Sort client-side by scheduledDate to avoid composite index requirements
          list.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
          return list;
        });
  }

  /// Stream today's meals for a specific userId
  Stream<List<MealModel>> getTodayMealsStream(String userId) {
    if (userId.isEmpty) return Stream.value([]);

    return getMealsStream(userId).map((meals) {
      final now = DateTime.now();
      return meals.where((meal) {
        return meal.scheduledDate.year == now.year &&
            meal.scheduledDate.month == now.month &&
            meal.scheduledDate.day == now.day;
      }).toList();
    });
  }

  /// Add a new meal
  Future<void> addMeal(MealModel meal) async {
    final docRef = meal.mealId.isEmpty ? _mealsCol.doc() : _mealsCol.doc(meal.mealId);
    final finalMeal = meal.copyWith(mealId: docRef.id);
    await docRef.set(finalMeal.toMap());
  }

  /// Update an existing meal
  Future<void> updateMeal(MealModel meal) async {
    await _mealsCol.doc(meal.mealId).update(meal.toMap());
  }

  /// Delete a meal by ID
  Future<void> deleteMeal(String mealId) async {
    await _mealsCol.doc(mealId).delete();
  }

  /// Toggle meal prepped status
  Future<void> toggleMealPrepped(String mealId, bool isPrepped) async {
    await _mealsCol.doc(mealId).update({'isPrepped': isPrepped});
  }

  // ==========================================
  // GROCERY ITEMS - REAL-TIME STREAMS & CRUD
  // ==========================================

  /// Stream all grocery items for a specific userId
  Stream<List<GroceryItemModel>> getGroceryItemsStream(String userId) {
    if (userId.isEmpty) return Stream.value([]);

    return _groceryCol
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => GroceryItemModel.fromFirestore(doc))
              .toList();
        });
  }

  /// Add a custom grocery item
  Future<void> addGroceryItem(GroceryItemModel item) async {
    final docRef = item.itemId.isEmpty ? _groceryCol.doc() : _groceryCol.doc(item.itemId);
    final finalItem = item.copyWith(itemId: docRef.id);
    await docRef.set(finalItem.toMap());
  }

  /// Toggle grocery item bought status
  Future<void> toggleGroceryItemBought(String itemId, bool isBought) async {
    await _groceryCol.doc(itemId).update({'isBought': isBought});
  }

  /// Delete a grocery item
  Future<void> deleteGroceryItem(String itemId) async {
    await _groceryCol.doc(itemId).delete();
  }

  /// Remove all purchased grocery items
  Future<void> clearBoughtGroceryItems(String userId) async {
    final snapshot = await _groceryCol
        .where('userId', isEqualTo: userId)
        .where('isBought', isEqualTo: true)
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// Auto-generate grocery list from planned meals:
  /// Extracts all ingredients, groups and categorizes them ("Produce", "Dairy", "Pantry"),
  /// avoids duplicates, and writes them to Cloud Firestore.
  Future<int> generateGroceryListFromMeals({
    required String userId,
    required List<MealModel> meals,
  }) async {
    if (meals.isEmpty || userId.isEmpty) return 0;

    // Fetch existing grocery items to avoid duplicates
    final existingSnapshot =
        await _groceryCol.where('userId', isEqualTo: userId).get();
    final existingNames = existingSnapshot.docs
        .map((doc) => (doc.data() as Map<String, dynamic>)['name']?.toString().toLowerCase().trim() ?? '')
        .toSet();

    // Collect all raw ingredient strings
    final Set<String> uniqueIngredients = {};
    for (final meal in meals) {
      for (final rawIngredient in meal.ingredients) {
        final cleaned = rawIngredient.trim();
        if (cleaned.isNotEmpty && !existingNames.contains(cleaned.toLowerCase())) {
          uniqueIngredients.add(cleaned);
        }
      }
    }

    if (uniqueIngredients.isEmpty) return 0;

    // Write batch to Firestore
    final batch = _firestore.batch();
    int addedCount = 0;

    for (final name in uniqueIngredients) {
      final docRef = _groceryCol.doc();
      final category = IngredientCategorizer.categorize(name);

      final item = GroceryItemModel(
        itemId: docRef.id,
        userId: userId,
        name: name,
        category: category,
        isBought: false,
      );

      batch.set(docRef, item.toMap());
      addedCount++;
    }

    await batch.commit();
    return addedCount;
  }

  // ==========================================
  // USER PROFILE
  // ==========================================

  /// Fetch user profile Stream
  Stream<UserModel?> getUserProfileStream(String userId) {
    if (userId.isEmpty) return Stream.value(null);

    return _usersCol.doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    });
  }

  /// Update user profile details
  Future<void> updateUserProfile(UserModel user) async {
    await _usersCol.doc(user.userId).set(user.toMap(), SetOptions(merge: true));
  }

  /// Update user display name (username) without modifying email
  Future<void> updateUserName(String userId, String name, {String? email}) async {
    final data = <String, dynamic>{
      'userId': userId,
      'name': name.trim(),
    };
    if (email != null && email.isNotEmpty) {
      data['email'] = email;
    }
    await _usersCol.doc(userId).set(data, SetOptions(merge: true));
  }

  /// Update daily calorie/meal target
  Future<void> updateCalorieTarget(
    String userId,
    int target, {
    String? name,
    String? email,
  }) async {
    final data = <String, dynamic>{
      'userId': userId,
      'calorieTarget': target,
    };
    if (name != null && name.isNotEmpty) {
      data['name'] = name;
    }
    if (email != null && email.isNotEmpty) {
      data['email'] = email;
    }
    await _usersCol.doc(userId).set(data, SetOptions(merge: true));
  }
}

