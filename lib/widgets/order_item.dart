import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shop_app/providers/order.dart';

class OrderItemW extends StatefulWidget {
  final OrderItem orderItem;

  OrderItemW(this.orderItem);

  @override
  _OrderItemWState createState() => _OrderItemWState();
}

class _OrderItemWState extends State<OrderItemW> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: _expanded ? min((widget.orderItem.products.length * 20) + 120, 200) : 96,
      child: Card(
        child: Column(
          children: [
            ListTile(
              title: Text('\$${widget.orderItem.amount}'),
              subtitle: Text(
                  DateFormat('dd MM yyyy').format(widget.orderItem.datetime)),
              trailing: IconButton(
                  onPressed: () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  },
                  icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more)),
            ),
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                margin: EdgeInsets.all(8),
                height: _expanded ? min((widget.orderItem.products.length * 20) + 24, 120) : 0,
                child: ListView(
                  children: widget.orderItem.products
                      .map((e) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                e.title,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text('${e.qty}x \$${e.price}',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey
                              ),)
                            ],
                          ))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
