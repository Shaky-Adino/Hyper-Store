import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Product with ChangeNotifier{

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final String id;
  final String title;
  final String category;
  final String description;
  final double price;
  final String imageUrl0, imageUrl1, imageUrl2, imageUrl3;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.category,
    @required this.description,
    @required this.price,
    @required this.imageUrl0,
    @required this.imageUrl1,
    @required this.imageUrl2,
    @required this.imageUrl3,
    this.isFavorite = false,
  });

  void _setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  Future<void> newtoggleFavoriteStatus(String userId) async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    try{
      await firestore.collection('userFavorites').doc(userId).collection('myFav').doc(id).set({
          'isFavorite': isFavorite
      });
    } catch (error) {
      print(error);
      _setFavValue(oldStatus);
    }
  }

  // Future<void> toggleFavoriteStatus(String token, String userId) async {
  //   final oldStatus = isFavorite;
  //   isFavorite = !isFavorite;
  //   notifyListeners();
  //   final url = Uri.parse('https://shop-app-9aa36.firebaseio.com/userFavorites/$userId/$id.json?auth=$token');

  //   try {
  //     final response = await http.put(
  //       url,
  //       body: json.encode(
  //         isFavorite,
  //       ),
  //     );
  //     if (response.statusCode >= 400) {
  //       _setFavValue(oldStatus);
  //     }
  //   } catch (error) {
  //     _setFavValue(oldStatus);
  //   }
  // }
}
