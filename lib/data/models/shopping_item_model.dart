import 'package:weekly_menu/data/models/ingredient_model.dart';

/// Modelo para items de la lista de compras
class ShoppingItemModel {
  final String id;
  final String userId;
  final String ingredientId;
  final String? quantity;
  final bool isPurchased;
  final IngredientModel ingredient;
  final DateTime createdAt;

  ShoppingItemModel({
    required this.id,
    required this.userId,
    required this.ingredientId,
    this.quantity,
    required this.isPurchased,
    required this.ingredient,
    required this.createdAt,
  });

  factory ShoppingItemModel.fromJson(Map<String, dynamic> json) {
    return ShoppingItemModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      ingredientId: json['ingredient_id'] as String,
      quantity: json['quantity'] as String?,
      isPurchased: json['is_purchased'] as bool,
      ingredient: IngredientModel.fromJson(json['ingredient']),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
