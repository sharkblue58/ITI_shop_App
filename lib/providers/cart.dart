import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';
import 'package:shop_app/models/http_exception.dart';

class CartItem {
  final String id;
  final String title;
  final int qty;
  final double price;

  CartItem(
      {required this.id,
      required this.title,
      required this.qty,
      required this.price});
}

class Cart with ChangeNotifier {
  String authToken;
  Map<String, CartItem> items = {};

  Cart(this.authToken,this.items);

  void updateUser(String token) {
    this.authToken = token;
    notifyListeners();
  }

  Map<String, CartItem> get getItems {
    return {...items};
  }

  int get itemCount {
    return items.isEmpty ? 0 : items.length;
  }

  double get totalAmount {
    double total = 0.0;
    items.forEach((key, value) {
      total += value.price * value.qty;
    });
    return total;
  }

  Future<void> fetchAndSetCart() async {
    final url = Uri.parse(
        'https://shop-app-f45aa-default-rtdb.asia-southeast1.firebasedatabase.app/cart.json?auth=$authToken');
    try {
      final response = await http.get(url);
      print(response);
      if (response.body.toString() != "null") {
        final extractedData =
            json.decode(response.body) as Map<String, dynamic>;
        extractedData.forEach((cartId, cartData) {
          items.putIfAbsent(
              cartId,
              () => CartItem(
                  id: cartData['productId'],
                  title: cartData['title'],
                  qty: cartData['qty'],
                  price: cartData['price']));
        });
      }

      notifyListeners();
    } catch (error) {
      print(error);
    }
  }

  Future<void> addItem(String productId, double price, String title) async {
    try {
      if (items.containsKey(productId)) {
        final url = Uri.parse(
            'https://shop-app-f45aa-default-rtdb.asia-southeast1.firebasedatabase.app/cart/$productId.json?auth=$authToken');

        final response = await http.patch(url,
            body: json.encode({'qty': items[productId]!.qty + 1}));

        if (response.statusCode >= 400) {
          notifyListeners();
          throw HttpException('could not update cart.');
        }

        items.update(
            productId,
            (value) => CartItem(
                id: value.id,
                title: value.title,
                qty: value.qty + 1,
                price: value.price));

        notifyListeners();
      } else {
        final url = Uri.parse(
            'https://shop-app-f45aa-default-rtdb.asia-southeast1.firebasedatabase.app/cart/$productId.json?auth=$authToken');

        final response = await http.put(url,
            body: json.encode({
              'productId': productId,
              'title': title,
              'qty': 1,
              'price': price,
            }));

        var res = json.decode(response.body);
        print(res);

        if (response.statusCode >= 400) {
          notifyListeners();
          throw HttpException('could not add item to cart.');
        }

        items.putIfAbsent(productId,
            () => CartItem(id: productId, title: title, qty: 1, price: price));

        notifyListeners();
      }
    } catch (ex) {
      print(ex.toString());
    }
  }

  Future<void> removeSingleItem(String productId) async {
    final url = Uri.parse(
        'https://shop-app-f45aa-default-rtdb.asia-southeast1.firebasedatabase.app/cart/$productId.json?auth=$authToken');

    if (items[productId]!.qty > 1) {
      final response = await http.patch(url,
          body: json.encode({'qty': items[productId]!.qty - 1}));

      if (response.statusCode >= 400) {
        notifyListeners();
        throw HttpException('could not update cart.');
      }

      items.update(
          productId,
          (value) => CartItem(
              id: value.id,
              title: value.title,
              qty: value.qty - 1,
              price: value.price));
    } else {
      final response = await http.delete(url);

      if (response.statusCode >= 400) {
        notifyListeners();
        throw HttpException('could not delete product.');
      }

      items.remove(productId);
    }

    notifyListeners();
  }

  Future<void> removeItem(String productId) async {
    final url = Uri.parse(
        'https://shop-app-f45aa-default-rtdb.asia-southeast1.firebasedatabase.app/cart/$productId.json?auth=$authToken');

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      notifyListeners();
      throw HttpException('could not remove product from cart.');
    }

  items.remove(productId);
    notifyListeners();
  }

  Future<void> clearCart() async {
    final url = Uri.parse(
        'https://shop-app-f45aa-default-rtdb.asia-southeast1.firebasedatabase.app/cart.json?auth=$authToken');

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      notifyListeners();
      throw HttpException('could not remove product from cart.');
    }

    items = {};
    notifyListeners();
  }
}
