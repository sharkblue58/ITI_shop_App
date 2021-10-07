import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/order.dart';
import 'package:shop_app/widgets/main_drawer.dart';
import 'package:shop_app/widgets/order_item.dart';

class Orders extends StatefulWidget {
  static const routeName = '/orders';

  @override
  _OrdersState createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  bool _isLoading = false;

  @override
  void initState() {
    _isLoading = true;


    Future.delayed(Duration.zero).then((_) async {
      await Provider.of<Order>(context, listen: false)
          .fetchAndSetOrder()
          .then((value) {
        setState(() {
          _isLoading = false;
        });
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _order = Provider.of<Order>(context);
    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemBuilder: (ctx, i) => OrderItemW(_order.getOrders[i]),
              itemCount: _order.getOrdersCount,
            ),
    );
  }
}
