import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/execeptions/http_exeception.dart';
import 'package:shop/models/product.dart';
import 'package:shop/utils/constants.dart';

class ProductList with ChangeNotifier {
  final List<Product> _items = [];
  List<Product> get items => [..._items];
  List<Product> get favoritesItems =>
      _items.where((product) => product.isFavorite).toList();

  int get itemsCount {
    return _items.length;
  }

  Future<void> loadProducts() async {
    _items.clear();

    final response = await http.get(
      Uri.parse('${Constants.baseUrl}.json'),
    );
    if (response.body == 'null') return;
    Map<String, dynamic> data = jsonDecode(response.body);
    data.forEach((productId, productData) {
      _items.add(
        Product(
          id: productId,
          name: productData['name'],
          description: productData['description'],
          price: productData['price'],
          imageUrl: productData['imageUrl'],
          isFavorite: productData['isFavorite'],
        ),
      );
    });
    notifyListeners();
  }

  Future<void> saveProduct(Map<String, dynamic> data) {
    bool hasId = data['id'] != null;

    final product = Product(
      id: hasId ? data['id'] as String : Random().nextDouble().toString(),
      name: data['name'] as String,
      price: data['price'] as double,
      description: data['description'] as String,
      imageUrl: data['imageUrl'] as String,
    );

    if (hasId) {
      return updateProduct(product);
    } else {
      return addProduct(product);
    }
  }

  Future<void> addProduct(Product product) async {
    final response = await http.post(
      Uri.parse('${Constants.baseUrl}.json'),
      body: jsonEncode(
        {
          'name': product.name,
          'price': product.price,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'isFavorite': product.isFavorite,
        },
      ),
    );

    final id = jsonDecode(response.body)['name'];
    _items.add(Product(
      id: id,
      name: product.name,
      description: product.description,
      price: product.price,
      imageUrl: product.imageUrl,
      isFavorite: product.isFavorite,
    ));
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    int index = _items.indexWhere((p) => p.id == product.id);

    if (index >= 0) {
      await http.patch(
        Uri.parse('${Constants.baseUrl}/${product.id}.json'),
        body: jsonEncode(
          {
            'name': product.name,
            'price': product.price,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'isFavorite': product.isFavorite,
          },
        ),
      );

      _items[index] = product;
      notifyListeners();
    }
  }

  Future<void> removeProduct(Product product) async {
    int index = _items.indexWhere((p) => p.id == product.id);

    if (index >= 0) {
      final product = _items[index];
      _items.remove(product);
      notifyListeners();

      final response = await http.delete(
        Uri.parse('${Constants.baseUrl}/${product.id}.json'),
      );

      if (response.statusCode >= 400) {
        _items.insert(index, product);
        notifyListeners();
        throw HttpExeception(
          message: 'Não foi possível remover o produto.',
          statusCode: response.statusCode,
        );
      }
    }
  }
}

// bool _showFavoritesOnly = false;

//   List<Product> get items {
//     if (_showFavoritesOnly) {
//       return _items.where((product) => product.isFavorite).toList();
//     }
//     return [..._items];
//   }

//   void showFavoritesOnly() {
//     _showFavoritesOnly = true;
//     notifyListeners();
//   }

//   void showAll() {
//     _showFavoritesOnly = false;
//     notifyListeners();
//   }
  
