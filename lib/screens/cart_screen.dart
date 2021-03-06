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
        title: const Text('Your Cart'),
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
                  const Text(
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

          if(cart.items.length == 0)
            Column(
              children: [
                CircleAvatar(
                  radius: 92,
                  child: Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Image.asset(
                      'assets/images/empty_cart.png', 
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your Cart is empty !', 
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18)
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: (){
                    Navigator.of(context).pop();
                  }, 
                  child: const Text(
                    'Continue shopping', 
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)
                  ),
                )
              ],
            ),
          if(cart.items.length > 0)
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
    return TextButton(
      child: _isLoading ? 
        CircularProgressIndicator() 
          : Text(
            'ORDER NOW',
            style: TextStyle(fontWeight: FontWeight.bold, color: widget.cart.totalAmount <= 0 ? Colors.grey : Colors.orange),
          ),
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
                        children: <Widget>[const Text("Update your profile with your contact information.")]
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
              bool orderPlaced = false;
              await showModalBottomSheet(
                context: context, 
                builder: (BuildContext context){
                  bool loading = false;
                  return StatefulBuilder(
                    builder : (context, setState){
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
                                  Text('₹${widget.cart.totalAmount.toStringAsFixed(2)}'),
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
                                  Text('₹${tax.toStringAsFixed(2)}'),
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
                                  setState((){
                                    loading = true;
                                  });
                                  await Provider.of<Orders>(context, listen: false).newaddOrder(
                                    widget.cart.items.values.toList(),
                                    total,
                                  );
                                  widget.cart.newclear();
                                  orderPlaced = true;
                                  Navigator.of(context).pop();
                                }, 
                                child: loading ? CircularProgressIndicator()
                                  : const Text('Confirm Order', style: TextStyle(fontWeight: FontWeight.bold))
                              ),
                            ],
                        ),
                      );
                    }
                  );
                }
              );
              setState(() {
                _isLoading = false;
              });
              if(orderPlaced)
                await showDialog(
                  context: context,
                  builder: (BuildContext context)
                    {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              const Icon(Icons.check, size: 45, color: Colors.green),
                              const SizedBox(height: 15),
                              const Text("Order placed successfully!"),
                              const SizedBox(height: 9),
                              const Text('Thank you for shopping on \nHyper Store')
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Close', style: TextStyle(color:Colors.black)),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                );
          },
    );
  }
}
