import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class RatingItem {
  final String id;
  final String name, imageUrl;
  final double stars;
  final String title, review;

  RatingItem({
    @required this.id,
    @required this.name,
    @required this.imageUrl,
    @required this.stars,
    @required this.title,
    @required this.review,
  });
}

class Rating extends ChangeNotifier{

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<RatingItem> _ratings = []; 

  double _avg = 0, _total = 0;

  bool _showAll = false;

  void update(bool value) {
    _showAll = value;
    notifyListeners();
  } 

  bool get showAll {
    return _showAll;
  }

  double get average {
    return _avg;
  }

  List<RatingItem> get ratings {
    return [..._ratings];
  }

  Future<void> fetchRatings(String prodId) async {
    var extractedData;
    try{
      QuerySnapshot querySnapshot = await firestore.collection('ratings').doc(prodId).collection('prodRating').get();
      extractedData = querySnapshot.docs;
      if (extractedData == null) {
        _ratings = [];
        return;
      }
      final List<RatingItem> loadedRatings = [];
      _total = 0;
      extractedData.forEach((item) {
        _total += item['stars'];
        loadedRatings.add(
          RatingItem(
            id: item.id, 
            name: item['name'], 
            imageUrl: item['imageUrl'], 
            stars: item['stars'], 
            title: item['title'], 
            review: item['review'],
          )
        );
      });
      _ratings = loadedRatings;
      if(_ratings.length > 0)
        _avg = _total/_ratings.length;
      notifyListeners();
    } catch(e){
      print(e);
    }
    
  }

  Future<void> addRating(String prodId, String name, String imageUrl, 
    double stars, String title, String review) async {
    try{
      DocumentReference docRef = await firestore.collection('ratings').doc(prodId)
        .collection('prodRating').add({
          'name': name,
          'imageUrl': imageUrl,
          'stars': stars,
          'title': title,
          'review': review,
        });
      
      final newRating = RatingItem(
        id: docRef.id, 
        name: name, 
        imageUrl: imageUrl, 
        stars: stars, 
        title: title, 
        review: review,
      );

      _total += stars;
      _ratings.add(newRating);
      _avg = _total/_ratings.length;
      notifyListeners();
    } catch(e){
      print(e);
    }
  }
}