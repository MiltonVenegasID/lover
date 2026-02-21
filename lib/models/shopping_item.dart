class ShoppingItem {
  final String id;
  final String name;
  final String quantity;
  final bool isChecked;

  const ShoppingItem({
    required this.id,
    required this.name,
    required this.quantity,
    this.isChecked = false,
  });

  ShoppingItem copyWith({
    String? id,
    String? name,
    String? quantity,
    bool? isChecked,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}
