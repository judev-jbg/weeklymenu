// lib/presentation/widgets/shopping_item_card.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/shopping_item_model.dart';

/// Card que muestra un item de la lista de compras
class ShoppingItemCard extends StatelessWidget {
  final ShoppingItemModel item;
  final VoidCallback onRemove;

  const ShoppingItemCard({
    Key? key,
    required this.item,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: Key(item.id),
        direction: DismissDirection.startToEnd,
        confirmDismiss: (direction) async {
          return await _showDeleteConfirmation(context);
        },
        onDismissed: (direction) {
          onRemove();
        },
        background: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 28,
          ),
        ),
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getCategoryColor(item.ingredient.category)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getCategoryIcon(item.ingredient.category),
                color: _getCategoryColor(item.ingredient.category),
                size: 20,
              ),
            ),
            title: Text(item.ingredient.name),
            subtitle: item.ingredient.category != null
                ? Text(item.ingredient.category!)
                : null,
            trailing: IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: () =>
                  _showDeleteConfirmation(context).then((confirmed) {
                if (confirmed == true) {
                  onRemove();
                }
              }),
            ),
          ),
        ),
      ),
    );
  }

  /// Muestra diálogo de confirmación
  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar compra'),
          content: Text('¿Ya compraste ${item.ingredient.name}?'),
          backgroundColor: Theme.of(Get.context!).cardTheme.color,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.only(left: 15, right: 15)),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  /// Obtiene el color según la categoría
  Color _getCategoryColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'verduras':
        return Colors.green;
      case 'proteínas':
        return Colors.red;
      case 'carbohidratos':
        return Colors.orange;
      case 'lácteos':
        return Colors.blue;
      case 'legumbres':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  /// Obtiene el icono según la categoría
  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'verduras':
        return Icons.eco;
      case 'proteínas':
        return Icons.restaurant;
      case 'carbohidratos':
        return Icons.grain;
      case 'lácteos':
        return Icons.local_drink;
      case 'legumbres':
        return Icons.scatter_plot;
      default:
        return Icons.fastfood;
    }
  }
}
