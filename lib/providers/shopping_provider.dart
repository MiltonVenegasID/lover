import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shopping_item.dart';

class ShoppingListNotifier extends StateNotifier<List<ShoppingItem>> {
  ShoppingListNotifier() : super([]);

  void addItem(String name, String quantity) {
    final newItem = ShoppingItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      quantity: quantity,
    );
    state = [...state, newItem];
  }

  void toggleItem(String id) {
    state = state.map((item) {
      if (item.id == id) {
        return item.copyWith(isChecked: !item.isChecked);
      }
      return item;
    }).toList();
  }

  void removeItem(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  void removeCheckedItems() {
    state = state.where((item) => !item.isChecked).toList();
  }
}

final shoppingListProvider =
    StateNotifierProvider<ShoppingListNotifier, List<ShoppingItem>>((ref) {
      return ShoppingListNotifier();
    });
