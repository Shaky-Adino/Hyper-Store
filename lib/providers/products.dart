import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/image_upload_model.dart';
import '../models/http_exception.dart';
import './product.dart';

class Products with ChangeNotifier{

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];
  // final String authToken;
  String userId;

  Products(this.userId, this._items);

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  void updates(String uid){
    userId = uid;
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  Future<void> newfetchAndSetProducts([bool filterByUser = false]) async {
    var extractedData;
    QuerySnapshot querySnapshot1, querySnapshot2;
    try {

      if(filterByUser)
        querySnapshot1 = await firestore.collection('products').where('creatorId', isEqualTo: userId).get();
      else
        querySnapshot1 = await firestore.collection('products').get();

      extractedData = querySnapshot1.docs;
      if (extractedData == null) {
        return;
      }
      querySnapshot2 = await firestore.collection('userFavorites').doc(userId).collection('myFav').get();
      final favoriteData = querySnapshot2.docs;
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodData) {
        loadedProducts.add(Product(
          id: prodData.id,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          isFavorite: favoriteData == null ? false : favoriteData[prodData.id]['isfavorite'] ?? false,
          imageUrl: prodData['imageUrl'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  // Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
  //   final filterString = filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
  //   Uri url = Uri.parse('https://shop-app-9aa36.firebaseio.com/products.json?auth=$authToken&$filterString');
  //   try {
  //     final response = await http.get(url);
  //     final extractedData = json.decode(response.body) as Map<String, dynamic>;
  //     if (extractedData == null) {
  //       return;
  //     }
  //     url = Uri.parse('https://shop-app-9aa36.firebaseio.com/userFavorites/$userId.json?auth=$authToken');
  //     final favoriteResponse = await http.get(url);
  //     final favoriteData = json.decode(favoriteResponse.body);
  //     final List<Product> loadedProducts = [];
  //     extractedData.forEach((prodId, prodData) {
  //       loadedProducts.add(Product(
  //         id: prodId,
  //         title: prodData['title'],
  //         description: prodData['description'],
  //         price: prodData['price'],
  //         isFavorite:
  //             favoriteData == null ? false : favoriteData[prodId] ?? false,
  //         imageUrl: prodData['imageUrl'],
  //       ));
  //     });
  //     _items = loadedProducts;
  //     notifyListeners();
  //   } catch (error) {
  //     throw (error);
  //   }
  // }

  Future<void> newaddProduct(Product product, List<ImageUploadModel> images) async{
    try
    {
      DocumentReference docRef = await firestore.collection('products').add({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'creatorId': userId,
      });
      final newProduct = Product(
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl,
          id: docRef.id,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  // Future<void> addProduct(Product product, List<ImageUploadModel> images) async {
  //   final url = Uri.parse('https://shop-app-9aa36.firebaseio.com/products.json?auth=$authToken');
  //   try {
  //     final response = await http.post(
  //       url,
  //       body: json.encode({
  //         'title': product.title,
  //         'description': product.description,
  //         'imageUrl': product.imageUrl,
  //         'price': product.price,
  //         'creatorId': userId,
  //       }),
  //     );
  //     final newProduct = Product(
  //       title: product.title,
  //       description: product.description,
  //       price: product.price,
  //       imageUrl: product.imageUrl,
  //       id: json.decode(response.body)['name'],
  //     );
  //     _items.add(newProduct);
  //     // _items.insert(0, newProduct); // at the start of the list
  //     notifyListeners();
      
  //   } catch (error) {
  //     print(error);
  //     throw error;
  //   }
  // }

  Future<void> newupdateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      await firestore.collection('products').doc(id).update({
          'title': newProduct.title,
          'description': newProduct.description,
          'imageUrl': newProduct.imageUrl,
          'price': newProduct.price
      });
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  // Future<void> updateProduct(String id, Product newProduct) async {
  //   final prodIndex = _items.indexWhere((prod) => prod.id == id);
  //   if (prodIndex >= 0) {
  //     final url = Uri.parse('https://shop-app-9aa36.firebaseio.com/products/$id.json?auth=$authToken');
  //     await http.patch(url,
  //         body: json.encode({
  //           'title': newProduct.title,
  //           'description': newProduct.description,
  //           'imageUrl': newProduct.imageUrl,
  //           'price': newProduct.price
  //         }));
  //     _items[prodIndex] = newProduct;
  //     notifyListeners();
  //   } else {
  //     print('...');
  //   }
  // }

  Future<void> newdeleteProduct(String id) async {
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    try{
      await firestore.collection('products').doc(id).delete();
    } catch(e){
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }

  // Future<void> deleteProduct(String id) async {
  //   final url = Uri.parse('https://shop-app-9aa36.firebaseio.com/products/$id.json?auth=$authToken');
  //   final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
  //   var existingProduct = _items[existingProductIndex];
  //   _items.removeAt(existingProductIndex);
  //   notifyListeners();
  //   final response = await http.delete(url);
  //   if (response.statusCode >= 400) {
  //     _items.insert(existingProductIndex, existingProduct);
  //     notifyListeners();
  //     throw HttpException('Could not delete product.');
  //   }
  //   existingProduct = null;
  // }
}
