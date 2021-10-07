import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/order.dart';
import 'package:shop_app/widgets/cart_item.dart';

class Carts extends StatefulWidget {
  static const routeName = '/cart';

  @override
  _CartsState createState() => _CartsState();
}

class _CartsState extends State<Carts> {
  bool _isInit = false;

  bool _isLoading = false;

  @override
  void initState() {
    // Provider.of<Products>(context).fetchAndSetProduct(); wont work
    // Future.delayed(Duration.zero).then((value) => {
    //   Provider.of<Products>(context).fetchAndSetProduct()
    // });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Cart>(context).fetchAndSetCart().then((value) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final _cart = Provider.of<Cart>(context);
    final _order = Provider.of<Order>(context, listen: false);

    Future<void> orderNow(List<CartItem> _cartItems, double total) async {
      setState(() {
        _isLoading = true;
      });

      await _order.addOrder(_cartItems, total).then((_) async {
        await _cart.clearCart();
      }).then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Card(
                  margin: EdgeInsets.all(15),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        Spacer(),
                        Chip(
                          label: Text(
                            '\$${_cart.totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .primaryTextTheme
                                    .headline6!
                                    .color),
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        TextButton(
                          onPressed: 
                          _cart.totalAmount <= 0? null: () async {
                            await orderNow(_cart.getItems.values.toList(),
                                _cart.totalAmount);
                          },
                          child: const Text(
                            'ORDER NOW',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                    child: ListView.builder(
                        itemCount: _cart.itemCount,
                        itemBuilder: (ctx, i) => CartItemW(
                            _cart.getItems.values.toList()[i].id,
                            _cart.getItems.keys.toList()[i],
                            _cart.getItems.values.toList()[i].title,
                            _cart.getItems.values.toList()[i].price,
                            _cart.getItems.values.toList()[i].qty))),
              ],
            ),
    );
  }
}
