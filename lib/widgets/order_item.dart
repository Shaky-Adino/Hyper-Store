import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/orders.dart';
import '../screens/product_detail_screen.dart';
import '../providers/products.dart';

import '../providers/orders.dart' as ord;

class OrderItem extends StatefulWidget {
  final ord.OrderItem order;

  OrderItem(this.order);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    bool show = !widget.order.cancelled && 
                    widget.order.dateTime.isAfter(DateTime.now().subtract(const Duration(days: 7)));
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height:
          _expanded ? max(widget.order.products.length * 115.0 + (show ? 140 : 110), 200) : (show ? 130 : 115),
      child: Card(
        margin: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text('₹${widget.order.amount}'),
              subtitle: Text(
                DateFormat('dd/MM/yyyy hh:mm').format(widget.order.dateTime),
              ),
              trailing: IconButton(
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              height: _expanded
                  ? max(widget.order.products.length * 115.0 + 10, 100)
                  : 0,
              child: ListView(
                children: widget.order.products
                    .map(
                      (prod) => InkWell(
                        onTap: (){
                          if(Provider.of<Products>(context, listen: false).findById(prod.prodId) == null)
                            return;
                          Navigator.of(context).pushNamed(
                            ProductDetailScreen.routeName,
                            arguments: prod.prodId,
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                                width: 90,
                                height: 90,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: CachedNetworkImage(
                                      imageUrl: prod.imageUrl,
                                      placeholder: (context, url) => CircularProgressIndicator(),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                            ),
                            Text(
                              prod.title,
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.black,
                                fontWeight: FontWeight.w600
                              ),
                            ),
                            // CircleAvatar(
                            //     backgroundColor: Colors.yellow,
                            //     child: Padding(
                            //     padding: EdgeInsets.all(4.0),
                            //       child: FittedBox(
                            //         child: Text(
                            //           '${prod.quantity}x  ₹${prod.price}', 
                            //           style: TextStyle(color: Colors.black),
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            Text(
                              '${prod.quantity}x  ₹${prod.price}',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black.withOpacity(0.7),
                              ),
                            )
                          ],
                        ),
                      ),
                    ).toList(),
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if(show)
                    ElevatedButton(
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (ctx) {
                            bool done = false, loading = false, refund = false;
                            String contentText = 'Do you want to cancel this order from Hyper Store?';
                            String titleText = 'Confirm the cancellation';
                            String buttonText = 'Yes';
                            return StatefulBuilder(
                              builder : (context, setState){
                                return AlertDialog(
                                  title: loading ? null : Text(titleText),
                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [loading ? CircularProgressIndicator() : Text(contentText),]
                                  ),
                                  actions: <Widget>[
                                    if(!refund && !loading)
                                      TextButton(
                                        child: Text('No',style: TextStyle(color:Colors.orange[700], fontWeight: FontWeight.bold)),
                                        onPressed: () {
                                          Navigator.of(ctx).pop(false);
                                        },
                                      ),
                                    if(!loading)
                                    TextButton(
                                      child: Text(buttonText,style: TextStyle(color:Colors.orange[700], fontWeight: FontWeight.bold)),
                                      onPressed: () async {
                                        if(refund)
                                          done = true;
                                        if(!refund){
                                          setState(() {
                                            loading = true;
                                          });
                                          await Provider.of<Orders>(context, listen: false).cancelOrder(widget.order.id);
                                          setState(() {
                                            loading = false;
                                            refund = true;
                                            titleText = 'Order cancelled';
                                            contentText = 'Your amount will be refunded in 3-4 business days';
                                            buttonText = 'OK';
                                          });
                                        }
                                        if(done)
                                          Navigator.of(ctx).pop(true);
                                      },
                                    ),
                                  ],
                                );
                              }
                            );
                          }
                        );
                      }, 
                      child: Text('Cancel Order')
                    ),
                  if(!show)
                    Container(
                      margin: const EdgeInsets.only(right: 10, bottom: 5),
                      child: Text(
                        widget.order.cancelled ? 'Cancelled' : 'Delivered',
                        style: TextStyle(
                          color: widget.order.cancelled ? Colors.orange : Colors.green,
                        ),
                      )
                    )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
