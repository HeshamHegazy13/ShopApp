import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './product_provider.dart';
import '../models/http_exception.dart';

final List<Product> products = [
  Product(
    id: 'p1',
    title: 'Red Shirt',
    description: 'A red shirt - it is pretty red!',
    price: 29.99,
    imageUrl:
        'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
  ),
  Product(
    id: 'p2',
    title: 'Trousers',
    description: 'A nice pair of trousers.',
    price: 59.99,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
  ),
  Product(
    id: 'p3',
    title: 'Yellow Scarf',
    description: 'Warm and cozy - exactly what you need for the winter.',
    price: 19.99,
    imageUrl: 'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
  ),
  Product(
    id: 'p4',
    title: 'A Pan',
    description: 'Prepare any meal you want.',
    price: 49.99,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
  ),
];

class Products with ChangeNotifier {
  final String authToken;
  final String userId;
  Products(this.authToken, this.userId, this._items);
  // var _showFavoritesOnly = false;
  // List<Product> _items = [
  //   Product(
  //     id: 'p1',
  //     title: 'Red Shirt',
  //     description: 'A red shirt - it is pretty red!',
  //     price: 29.99,
  //     imageUrl:
  //         'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
  //   ),
  //   Product(
  //     id: 'p2',
  //     title: 'Trousers',
  //     description: 'A nice pair of trousers.',
  //     price: 59.99,
  //     imageUrl:
  //         'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
  //   ),
  //   Product(
  //     id: 'p3',
  //     title: 'Yellow Scarf',
  //     description: 'Warm and cozy - exactly what you need for the winter.',
  //     price: 19.99,
  //     imageUrl:
  //         'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
  //   ),
  //   Product(
  //     id: 'p4',
  //     title: 'A Pan',
  //     description: 'Prepare any meal you want.',
  //     price: 49.99,
  //     imageUrl:
  //         'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
  //   ),
  // ];
  List<Product> _items = [];

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return [..._items.where((product) => product.isFavorite == true)];
    // }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return [..._items.where((product) => product.isFavorite == true)];
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  // void showFavoritsOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }
  Future<void> addProduct(Product product) async {
    final url =
        'https://shopapp-90225-default-rtdb.firebaseio.com/products.json?auth=$authToken';

    try {
      final response = await http.post(url,
          body: json.encode({
            'Title': product.title,
            'Description': product.description,
            'Price': product.price,
            'imageUrl': product.imageUrl,
            'creatorId': userId
          }));
      final newProduct = Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);
      _items.insert(0, newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw (error);
    }

    // _items.add(value);
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final url =
        'https://shopapp-90225-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
    try {
      await http.patch(url,
          body: json.encode({
            'Title': newProduct.title,
            'Description': newProduct.description,
            'Price': newProduct.price,
            'isFav': newProduct.isFavorite,
            'imageUrl': newProduct.imageUrl
          }));

      final index = _items.indexWhere((prod) => prod.id == id);
      _items[index] = newProduct;
      notifyListeners();
    } catch (e) {}
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://shopapp-90225-default-rtdb.firebaseio.com/products.$id.json?auth=$authToken';
    final existingIndexProduct =
        _items.indexWhere((element) => element.id == id);
    var existingProduct = _items[existingIndexProduct];

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      _items.insert(existingIndexProduct, existingProduct);
      throw HttpException('Could Not Delete Product');
    } else {
      existingProduct = null;
      _items.removeAt(existingIndexProduct);
    }

    notifyListeners();
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    final url =
        'https://shopapp-90225-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString';

    final urlFavProd =
        'https://shopapp-90225-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken';

    try {
      final response = await http.get(url);
      final responseFav = await http.get(urlFavProd);
      // print(json.decode(response.body));
      final extractData = json.decode(response.body) as Map<String, dynamic>;
      final extractFav = json.decode(responseFav.body) as Map<String, bool>;

      List<Product> _loadedData = [];

      extractData.forEach((prodId, prodData) {
        _loadedData.insert(
            0,
            Product(
                isFavorite:
                    extractFav == null ? false : extractFav[prodId] ?? false,
                id: prodId,
                title: prodData['Title'],
                description: prodData['Description'],
                price: prodData['Price'],
                imageUrl: prodData['imageUrl']));
      });
      _items = _loadedData;
    } catch (e) {
      throw e;
    }
    notifyListeners();
  }
}
