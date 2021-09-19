import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import './user_profile.dart';
import '../providers/auth.dart';

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
          const SizedBox(height: 10),
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
  bool _isLoading = false, _done = false;

  @override
  Widget build(BuildContext context) {
    var tax = widget.cart.totalAmount*0.1;
    var total = widget.cart.totalAmount + tax + 80;
    return FlatButton(
      child: _isLoading ? CircularProgressIndicator() : Text('ORDER NOW',style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),),
      onPressed: (widget.cart.totalAmount <= 0 || _isLoading)
          ? null
          : () async {
            final authData = Provider.of<Auth>(context, listen: false);
            String username = authData.username;
            String url = authData.userImage;
            String phone = authData.userPhone;
            String address = authData.userAddress;
            if(phone == '' || address == ''){
              await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context)
                {
                  return AlertDialog(
                    title: const Text('Add your address !'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[Text("Update your profile with your contact information.")]
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Later', style: TextStyle(color:Colors.orange[700], fontWeight: FontWeight.bold)),
                        onPressed: () {
                          _done = false;
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text('Update Now', style: TextStyle(color:Colors.orange[700], fontWeight: FontWeight.bold)),
                        onPressed: () {
                          _done = true;
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
              if(!_done)
                return;
              bool updated = await Navigator.push(
                                context, 
                                MaterialPageRoute(builder: (context) => UserProfile(username, url, phone, address))
                              );
              if(!updated)
                return;
            }
              setState(() {
                _isLoading = true;
              });
              await showModalBottomSheet(
                context: context, 
                builder: (BuildContext context){
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Summary', style: TextStyle(fontSize: 20)),
                          const SizedBox(height: 10),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Estimated Shipping Date:'),
                              Text(DateFormat('EEE, MMM d').format(DateTime.now().add(const Duration(days: 7)))),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Mode of payment:'),
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.yellow[200],
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(40.0),
                                    bottomRight: Radius.circular(40.0),
                                    topLeft: Radius.circular(40.0),
                                    bottomLeft: Radius.circular(40.0)
                                  ),
                                ),
                                child: const Text('Cash On Delivery'),
                              ),
                            ],
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Subtotal:'),
                              Text('₹${widget.cart.totalAmount.toString()}'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Delivery Charge:'),
                              const Text('₹80'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Tax:'),
                              Text('₹$tax'),
                            ],
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Order Total:', style: TextStyle(fontWeight: FontWeight.bold),),
                              Text('₹$total', style: TextStyle(fontWeight: FontWeight.bold),),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () async {
                              await Provider.of<Orders>(context, listen: false).newaddOrder(
                                widget.cart.items.values.toList(),
                                total,
                              );
                              widget.cart.newclear();
                              Navigator.of(context).pop();
                            }, 
                            child: Text('Confirm Order', style: TextStyle(fontWeight: FontWeight.bold),)
                          ),
                        ],
                      ),
                  );
                }
              );
              setState(() {
                _isLoading = false;
              });
            },
      textColor: Theme.of(context).primaryColor,
    );
  }
}
