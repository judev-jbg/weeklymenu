/// Modelo para ingredientes e insumos
class IngredientModel {
  final String id;
  final String name;
  final String? category;
  final String? createdBy;
  final DateTime createdAt;

  IngredientModel({
    required this.id,
    required this.name,
    this.category,
    this.createdBy,
    required this.createdAt,
  });

  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    return IngredientModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
