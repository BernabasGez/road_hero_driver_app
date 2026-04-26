import 'package:flutter_bloc/flutter_bloc.dart';
// Fixed path to reach the data/models folder
import '../../data/models/cart_item_model.dart';

class CartState {
  final List<CartItemModel> items;
  final int? garageId;

  CartState({this.items = const [], this.garageId});

  double get totalCartPrice => items.fold(0.0, (sum, item) => sum + item.total);
}

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartState());

  void addToCart(CartItemModel newItem) {
    if (state.garageId != null && state.garageId != newItem.garageId) {
      emit(CartState(items: [newItem], garageId: newItem.garageId));
      return;
    }

    final existingIndex = state.items.indexWhere((i) => i.id == newItem.id);
    if (existingIndex >= 0) {
      final updatedItems = List<CartItemModel>.from(state.items);
      updatedItems[existingIndex].quantity += 1;
      emit(CartState(items: updatedItems, garageId: newItem.garageId));
    } else {
      emit(
        CartState(items: [...state.items, newItem], garageId: newItem.garageId),
      );
    }
  }

  void removeItem(int id) {
    final updated = state.items.where((i) => i.id != id).toList();
    emit(
      CartState(
        items: updated,
        garageId: updated.isEmpty ? null : state.garageId,
      ),
    );
  }

  void clearCart() => emit(CartState());
}
