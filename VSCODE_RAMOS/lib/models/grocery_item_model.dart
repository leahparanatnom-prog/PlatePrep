import 'package:cloud_firestore/cloud_firestore.dart';

class GroceryItemModel {
  final String itemId;
  final String userId;
  final String name;
  final String category; // "Produce", "Dairy", "Pantry"
  final bool isBought;

  GroceryItemModel({
    required this.itemId,
    required this.userId,
    required this.name,
    required this.category,
    this.isBought = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'userId': userId,
      'name': name,
      'category': category,
      'isBought': isBought,
    };
  }

  factory GroceryItemModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return GroceryItemModel(
      itemId: id ?? map['itemId'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? 'Item',
      category: map['category'] ?? 'Pantry',
      isBought: map['isBought'] ?? false,
    );
  }

  factory GroceryItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return GroceryItemModel.fromMap(data, id: doc.id);
  }

  GroceryItemModel copyWith({
    String? itemId,
    String? userId,
    String? name,
    String? category,
    bool? isBought,
  }) {
    return GroceryItemModel(
      itemId: itemId ?? this.itemId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      category: category ?? this.category,
      isBought: isBought ?? this.isBought,
    );
  }
}

