import 'package:flutter/material.dart';
import '../../data/models/shopping_item_model.dart';

/// Card que muestra un item de la lista de compras
class ShoppingItemCard extends StatelessWidget {
  final ShoppingItemModel item;
  final VoidCallback onTogglePurchased;
  final VoidCallback onRemove;

  const ShoppingItemCard({
    Key? key,
    required this.item,
    required this.onTogglePurchased,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Checkbox(
            value: item.isPurchased,
            onChanged: (_) => onTogglePurchased(),
          ),
          title: Text(
            item.ingredient.name,
            style: TextStyle(
              decoration: item.isPurchased ? TextDecoration.lineThrough : null,
              color: item.isPurchased ? Colors.grey[600] : null,
            ),
          ),
          subtitle: item.ingredient.category != null
              ? Text(item.ingredient.category!)
              : null,
          trailing: IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: onRemove,
          ),
        ),
      ),
    );
  }
}
