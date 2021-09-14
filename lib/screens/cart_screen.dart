import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart' show Cart;
import '../widgets/cart_item.dart';
import '../providers/orders.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Column(
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      '₹${cart.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color:
                            Theme.of(context).primaryTextTheme.headline6.color,
                      ),
                    ),
                    backgroundColor: Colors.orange,
                  ),
                  OrderButton(cart: cart)
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (ctx, i) => CartItem(
                cart.items.values.toList()[i].id,
                cart.items.keys.toList()[i],
                cart.items.values.toList()[i].price,
                cart.items.values.toList()[i].quantity,
                cart.items.values.toList()[i].title,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    var tax = widget.cart.totalAmount*0.1;
    var total = widget.cart.totalAmount + tax + 80;
    return FlatButton(
      child: _isLoading ? CircularProgressIndicator() : Text('ORDER NOW',style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),),
      onPressed: (widget.cart.totalAmount <= 0 || _isLoading)
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });
              await showDialog(
                context: context, 
                builder: (BuildContext context){
                  return AlertDialog(
                    title: const Text('Summary'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Estimated Shipping Date:'),
                            Text(DateFormat('EEE, MMM d').format(DateTime.now().add(const Duration(days: 7)))),
                          ],
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Subtotal:'),
                            Text('₹${widget.cart.totalAmount.toString()}'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Delivery Charge:'),
                            Text('₹80'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Tax:'),
                            Text('₹$tax'),
                          ],
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Order Total:'),
                            Text('₹$total'),
                          ],
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: (){
                            
                          }, 
                          child: Text('Confirm Order')
                        ),
                      ],
                    ),
                  );
                }
              );
              await Provider.of<Orders>(context, listen: false).newaddOrder(
                widget.cart.items.values.toList(),
                total,
              );
              setState(() {
                _isLoading = false;
              });
              widget.cart.newclear();
            },
      textColor: Theme.of(context).primaryColor,
    );
  }
}
