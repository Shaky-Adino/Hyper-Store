import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;
  final bool cancelled;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
    @required this.cancelled,
  });
}

class Orders with ChangeNotifier{

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<OrderItem> _orders = [];
  Map<String, bool> _products = {};
  // final String authToken;
  String userId;

  // Orders(this.userId, this._orders);

  void updates(String uid){
    userId = uid;
  }

  List<OrderItem> get orders {
    return [..._orders];
  }

  Map<String, bool> get products {
    return {..._products};
  }

  Future<void> newfetchAndSetOrders() async {
    final List<OrderItem> loadedOrders = [];
    QuerySnapshot querySnapshot = await firestore.collection('orders').doc(userId).collection('myorder').orderBy('dateTime').get();
    final extractedData = querySnapshot.docs;
    if (extractedData == null) {
      return;
    }
    extractedData.forEach((orderData) {
      loadedOrders.add(
        OrderItem(
          id: orderData.id,
          amount: orderData['amount'],
          dateTime: DateTime.parse(orderData['dateTime']),
          cancelled: orderData['cancelled'],
          products: (orderData['products'] as List<dynamic>)
              .map(
                (item) {
                  if(!orderData['cancelled'])
                    _products[item['productId']] = true;
                  return CartItem(
                    id: item['id'],
                    prodId: item['productId'],
                    imageUrl: item['imageUrl'],
                    price: item['price'],
                    quantity: item['quantity'],
                    title: item['title'],
                  );
              }
              )
              .toList(),
        ),
      );
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  // Future<void> fetchAndSetOrders() async {
  //   final url = Uri.parse('https://shop-app-9aa36.firebaseio.com/orders/$userId.json?auth=$authToken');
  //   final response = await http.get(url);
  //   final List<OrderItem> loadedOrders = [];
  //   final extractedData = json.decode(response.body) as Map<String, dynamic>;
  //   if (extractedData == null) {
  //     return;
  //   }
  //   extractedData.forEach((orderId, orderData) {
  //     loadedOrders.add(
  //       OrderItem(
  //         id: orderId,
  //         amount: orderData['amount'],
  //         dateTime: DateTime.parse(orderData['dateTime']),
  //         products: (orderData['products'] as List<dynamic>)
  //             .map(
  //               (item) => CartItem(
  //                 id: item['id'],
  //                 price: item['price'],
  //                 quantity: item['quantity'],
  //                 title: item['title'],
  //               ),
  //             )
  //             .toList(),
  //       ),
  //     );
  //   });
  //   _orders = loadedOrders.reversed.toList();
  //   notifyListeners();
  // }

  Future<void> newaddOrder(List<CartItem> cartProducts, double total) async {
    final timestamp = DateTime.now();

    DocumentReference docRef = await firestore.collection('orders').doc(userId).collection('myorder').add({
        'amount': total,
        'dateTime': timestamp.toIso8601String(),
        'cancelled': false,
        'products': cartProducts.map((cp) => {
                      'id': cp.id,
                      'productId': cp.prodId,
                      'title': cp.title,
                      'imageUrl': cp.imageUrl,
                      'quantity': cp.quantity,
                      'price': cp.price,
                    }).toList(),
    });

    cartProducts.map((cp) {
      _products[cp.prodId] = true;
    });

    _orders.insert(
      0,
      OrderItem(
        id: docRef.id,
        amount: total,
        dateTime: timestamp,
        products: cartProducts,
        cancelled: false,
      ),
    );
    notifyListeners();
  }

  Future<void> cancelOrder(String orderId) async {
    await firestore.collection('orders').doc(userId)
            .collection('myorder').doc(orderId).update({
              'cancelled': true,
            });
    notifyListeners();
  }

  // Future<void> addOrder(List<CartItem> cartProducts, double total) async {
  //   final url = Uri.parse('https://shop-app-9aa36.firebaseio.com/orders/$userId.json?auth=$authToken');
  //   final timestamp = DateTime.now();
  //   final response = await http.post(
  //     url,
  //     body: json.encode({
  //       'amount': total,
  //       'dateTime': timestamp.toIso8601String(),
  //       'products': cartProducts
  //           .map((cp) => {
  //                 'id': cp.id,
  //                 'title': cp.title,
  //                 'quantity': cp.quantity,
  //                 'price': cp.price,
  //               })
  //           .toList(),
  //     }),
  //   );
  //   _orders.insert(
  //     0,
  //     OrderItem(
  //       id: json.decode(response.body)['name'],
  //       amount: total,
  //       dateTime: timestamp,
  //       products: cartProducts,
  //     ),
  //   );
  //   notifyListeners();
  // }
}
