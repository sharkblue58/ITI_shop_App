import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/models/http_exception.dart';
import 'package:shop_app/providers/product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Products with ChangeNotifier {
  String authToken;
  String userId;
  List<Product> _items = [];

  Products(this.authToken, this.userId, this._items);

  void updateUser(String token, String id) {
    this.userId = id;
    this.authToken = token;
    notifyListeners();
  }

  List<Product> get items {
    return [..._items];
  }

  List<Product> get getFavorites {
    return _items.where((e) => e.isFavorite).toList();
  }

  Product getProductById(String productId) {
    return _items.firstWhere((e) => e.id == productId);
  }

  Future<void> fetchAndSetProduct([bool filterUser = false]) async {
    final filterString =
        filterUser ? '&orderBy="creatorId"&equalTo="$userId"' : '';

    final url = Uri.parse(
        'https://shop-app-f45aa-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$authToken$filterString');
    final favoriteUrl = Uri.parse(
        'https://shop-app-f45aa-default-rtdb.asia-southeast1.firebasedatabase.app/userFavorites/$userId.json?auth=$authToken');
    try {
      final response = await http.get(url);
      final favoriteReponse = await http.get(favoriteUrl);
      final favoriteData = json.decode(favoriteReponse.body);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      List<Product> loadedData = [];
      extractedData.forEach((prodId, prodData) {
        loadedData.add(Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            imageUrl: prodData['imageUrl'],
            isFavorite:
                favoriteData == null ? false : favoriteData[prodId] ?? false,
            price: prodData['price']));
      });

      _items = loadedData;
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> addProduct(Product _newProduct) async {
    final url = Uri.parse(
        'https://shop-app-f45aa-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$authToken');

    try {
      final response = await http.post(url,
          body: json.encode({
            'title': _newProduct.title,
            'description': _newProduct.description,
            'imageUrl': _newProduct.imageUrl,
            'price': _newProduct.price,
            'creatorId': userId
            // 'isFavorite': _newProduct.isFavorite
          }));

      var res = json.decode(response.body);
      print(res);

      final newProduct = Product(
          id: res['name'],
          title: _newProduct.title,
          description: _newProduct.description,
          price: _newProduct.price,
          imageUrl: _newProduct.imageUrl);

      _items.add(newProduct);
      print(newProduct.id);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(Product _editedProduct) async {
    final _prodIndex = _items.indexWhere((e) => e.id == _editedProduct.id);

    if (_prodIndex > 0) {
      final url = Uri.parse(
          'https://shop-app-f45aa-default-rtdb.asia-southeast1.firebasedatabase.app/products/${_editedProduct.id}.json?auth=$authToken');

      await http.patch(url,
          body: json.encode({
            'title': _editedProduct.title,
            'description': _editedProduct.description,
            'price': _editedProduct.price,
            'imageUrl': _editedProduct.imageUrl
          }));
      _items[_prodIndex] = _editedProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String _productId) async {
    final url = Uri.parse(
        'https://shop-app-f45aa-default-rtdb.asia-southeast1.firebasedatabase.app/products/$_productId.json?auth=$authToken');
    var existingProduct = _items.firstWhere((e) => e.id == _productId);
    _items.removeWhere((e) => e.id == _productId);
    notifyListeners();

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      print(response.body);
      _items.add(existingProduct);
      notifyListeners();
      throw HttpException('could not delete product.');
    }
  }

  Future<void> toggleFavorite(
      String _productId, bool isFavorite, String _userId) async {
    var _product = _items.firstWhere((e) => e.id == _productId);

    final url = Uri.parse(
        'https://shop-app-f45aa-default-rtdb.asia-southeast1.firebasedatabase.app/userFavorites/$_userId/$_productId.json?auth=$authToken');

    final response = await http.put(url, body: json.encode(!isFavorite));

    if (response.statusCode >= 400) {
      notifyListeners();
      throw HttpException('could not change item Favorite.');
    }

    _product.isFavorite = !isFavorite;
    notifyListeners();
  }
}
