import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/shopping_provider.dart';

class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  ConsumerState<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends ConsumerState<ShoppingListScreen> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shoppingList = ref.watch(shoppingListProvider);
    final uncheckedItems = shoppingList
        .where((item) => !item.isChecked)
        .toList();
    final checkedItems = shoppingList.where((item) => item.isChecked).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Compras'),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          if (checkedItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                ref.read(shoppingListProvider.notifier).removeCheckedItems();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Items removidos de la lista'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              tooltip: 'Eliminar items marcados',
            ),
        ],
      ),
      body: Column(
        children: [
          // Add item form
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(color: Colors.green.withOpacity(0.3)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agregar ítem a la lista',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del ítem',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: Icon(Icons.shopping_basket),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Cantidad',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton(
                      onPressed: _addItem,
                      backgroundColor: Colors.green,
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Shopping list
          Expanded(
            child: shoppingList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay ítems en tu lista',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: Colors.grey[400]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Agrega ítems arriba para comenzar',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (uncheckedItems.isNotEmpty) ...[
                        Text(
                          'Por Comprar (${uncheckedItems.length})',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                        ),
                        const SizedBox(height: 12),
                        ...uncheckedItems.map(
                          (item) => _ShoppingItemCard(
                            item: item,
                            onToggle: () => ref
                                .read(shoppingListProvider.notifier)
                                .toggleItem(item.id),
                            onDelete: () => ref
                                .read(shoppingListProvider.notifier)
                                .removeItem(item.id),
                          ),
                        ),
                      ],
                      if (uncheckedItems.isNotEmpty && checkedItems.isNotEmpty)
                        const SizedBox(height: 24),
                      if (checkedItems.isNotEmpty) ...[
                        Text(
                          'Completados (${checkedItems.length})',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                        ),
                        const SizedBox(height: 12),
                        ...checkedItems.map(
                          (item) => _ShoppingItemCard(
                            item: item,
                            onToggle: () => ref
                                .read(shoppingListProvider.notifier)
                                .toggleItem(item.id),
                            onDelete: () => ref
                                .read(shoppingListProvider.notifier)
                                .removeItem(item.id),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  void _addItem() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa el nombre del ítem'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    ref
        .read(shoppingListProvider.notifier)
        .addItem(
          _nameController.text.trim(),
          _quantityController.text.trim().isEmpty
              ? '1'
              : _quantityController.text.trim(),
        );

    _nameController.clear();
    _quantityController.clear();

    // Hide keyboard
    FocusScope.of(context).unfocus();
  }
}

class _ShoppingItemCard extends StatelessWidget {
  const _ShoppingItemCard({
    required this.item,
    required this.onToggle,
    required this.onDelete,
  });

  final dynamic item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: item.isChecked ? 1 : 2,
      child: ListTile(
        leading: Checkbox(
          value: item.isChecked,
          onChanged: (_) => onToggle(),
          activeColor: Colors.green,
        ),
        title: Text(
          item.name,
          style: TextStyle(
            decoration: item.isChecked ? TextDecoration.lineThrough : null,
            color: item.isChecked ? Colors.grey : Colors.black,
            fontWeight: item.isChecked ? FontWeight.normal : FontWeight.w500,
          ),
        ),
        subtitle: Text(
          'Cantidad: ${item.quantity}',
          style: TextStyle(
            color: item.isChecked ? Colors.grey : Colors.grey[600],
            fontSize: 12,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          color: Colors.red[300],
          onPressed: onDelete,
        ),
      ),
    );
  }
}
