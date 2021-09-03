import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/http_exception.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    @required this.id,
    @required this.title,
    @required this.quantity,
    @required this.price,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};
  final String authToken;
  final String userId;

  Cart(this.authToken, this.userId, this._items);

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  Future<void> fetchAndSetCartItems() async {
    final url = Uri.parse('https://shop-app-9aa36.firebaseio.com/cart/$userId.json?auth=$authToken');
    final response = await http.get(url);
    final Map<String, CartItem> loadedItems = {};
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }
    extractedData.forEach((itemId, itemData) {
      loadedItems[itemData['productId']] = CartItem(id: itemId, 
                                                title: itemData['title'], 
                                                quantity: itemData['quantity'], 
                                                price: itemData['price']);
    });
    _items = loadedItems;
    notifyListeners();
  }

  Future<void> addItem(String productId,double price,String title,[int q = 1]) async {
    
    if (_items.containsKey(productId)) {
      // change quantity...
      final String id1 = _items[productId].id;
      int quant = _items[productId].quantity;
      final url = Uri.parse('https://shop-app-9aa36.firebaseio.com/cart/$userId/$id1.json?auth=$authToken');
      try{
        final response = await http.patch(
          url,
          body: json.encode({
            'quantity': quant + q,
          }),
        );
        if (response.statusCode >= 400) {
            throw HttpException('Could not add cart item.');
        }
        _items.update(
          productId,
          (existingCartItem) => CartItem(
                id: existingCartItem.id,
                title: existingCartItem.title,
                price: existingCartItem.price,
                quantity: existingCartItem.quantity + q,
              ),
        );
      } catch (error) {
        print(error);
        throw error;
      }
    } else {
      final url = Uri.parse('https://shop-app-9aa36.firebaseio.com/cart/$userId.json?auth=$authToken');
        try {
        final response = await http.post(
          url,
          body: json.encode({
            'title': title,
            'price': price,
            'productId': productId,
            'quantity': q,
          }),
        );
        _items.putIfAbsent(
          productId,
          () => CartItem(
                id: json.decode(response.body)['name'],
                title: title,
                price: price,
                quantity: q,
              ),
        );
      } catch (error) {
        print(error);
        throw error;
      }
    }
    notifyListeners();
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  Future<void> removeItem(String productId) async {
    final id1 = _items[productId].id;
    final url = Uri.parse('https://shop-app-9aa36.firebaseio.com/cart/$userId/$id1.json?auth=$authToken');
    var existingItem = _items[productId];
    _items.remove(productId);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items[productId] = existingItem;
      notifyListeners();
      throw HttpException('Could not delete cart item.');
    }
    existingItem = null;
  }

  Future<void> removeSingleItem(String productId, [int q = 1]) async {
    if (!_items.containsKey(productId)) {
      return;
    }

    final id1 = _items[productId].id;
    final url = Uri.parse('https://shop-app-9aa36.firebaseio.com/cart/$userId/$id1.json?auth=$authToken');
    int quant = _items[productId].quantity;

    if (quant > q) {
      try{
        final response = await http.patch(
          url,
          body: json.encode({
            'quantity': quant - q,
          }),
        );
        if (response.statusCode >= 400) {
            throw HttpException('Could not delete cart item.');
        }
        _items.update(
          productId,
          (existingCartItem) => CartItem(
                id: existingCartItem.id,
                title: existingCartItem.title,
                price: existingCartItem.price,
                quantity: existingCartItem.quantity - q,
              ),
        );
      } catch (error) {
        print(error);
        throw error;
      }
      notifyListeners();
    } else {
      var existingItem = _items[productId];
      _items.remove(productId);
      notifyListeners();
      final response = await http.delete(url);
      if (response.statusCode >= 400) {
        _items[productId] = existingItem;
        notifyListeners();
        throw HttpException('Could not delete cart item.');
      }
      existingItem = null;
    }
  }

  Future<void> clear() async {
    final url = Uri.parse('https://shop-app-9aa36.firebaseio.com/cart/$userId.json?auth=$authToken');
    await http.delete(url);
    _items = {};
    notifyListeners();
  }
}
