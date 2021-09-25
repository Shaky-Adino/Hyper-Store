import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/orders.dart';
import '../providers/product.dart';

class OrderConfirmation extends StatefulWidget {
  final Product prod;
  final int quantity;

  const OrderConfirmation(this.prod, this.quantity);
  

  @override
  _OrderConfirmationState createState() => _OrderConfirmationState();
}

class _OrderConfirmationState extends State<OrderConfirmation> {
  
  @override
  Widget build(BuildContext context) {
    final double subTotal = widget.prod.price*widget.quantity;
    final double tax = subTotal*0.1;
    final double total = subTotal + tax + 80;
    bool loading = false;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10, top: 55),
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
                Text('₹${subTotal.toString()}'),
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
                setState((){
                  loading = true;
                });
                await Provider.of<Orders>(context, listen: false).addSingleOrder(
                  widget.prod,
                  widget.quantity,
                  total,
                );
                await showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder:  (BuildContext context)
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
                              const Text('Thank you for shopping on Hyper Store')
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
                Navigator.of(context).pop();
              }, 
              child: loading ? CircularProgressIndicator()
                        : const Text('Confirm Order', style: TextStyle(fontWeight: FontWeight.bold))
            ),

            const SizedBox(height: 30),

            if(!loading)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.redAccent,
                ),
                onPressed: (){
                  Navigator.of(context).pop();
                }, 
                child: const Text('CANCEL', style: TextStyle(color: Colors.white))
              ),
          ],
        ),
      ),
    );
  }
}