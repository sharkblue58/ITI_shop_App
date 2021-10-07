import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/product_details.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _product = Provider.of<Product>(context, listen: false);
    final _cart = Provider.of<Cart>(context, listen: false);
    final _authData = Provider.of<Auth>(context, listen: false);

    final scaffold = ScaffoldMessenger.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        header: Text(_product.title),
        child: GestureDetector(
          child: Hero(
            tag: _product.id,
            child: FadeInImage(
                placeholder: AssetImage('assets/images/product-placeholder.png'),
                image: NetworkImage(_product.imageUrl),
                fit: BoxFit.cover,),
          ),
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetails.routeName,
              arguments: _product.id,
            );
          },
        ),
        footer: GridTileBar(
          leading: Consumer<Products>(
            builder: (ctx, _productsFunction, _) => IconButton(
              onPressed: () async {
                try {
                  _productsFunction.toggleFavorite(
                      _product.id, _product.isFavorite, _authData.userId);
                  scaffold.hideCurrentSnackBar();
                  _product.isFavorite
                      ? scaffold.showSnackBar(SnackBar(
                          content:
                              Text("${_product.title} removed from Favorite")))
                      : scaffold.showSnackBar(SnackBar(
                          content:
                              Text("${_product.title} added to Favorite")));
                } catch (ex) {
                  scaffold.hideCurrentSnackBar();
                  scaffold.showSnackBar(SnackBar(content: Text(ex.toString())));
                }
              },
              icon: Icon(_product.isFavorite
                  ? Icons.favorite
                  : Icons.favorite_outline),
              color: Theme.of(context).accentColor,
            ),
          ),
          backgroundColor: Colors.black87,
          title: Text(
            '\$${_product.price.toStringAsFixed(2)}',
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            onPressed: () async {
              await _cart
                  .addItem(_product.id, _product.price, _product.title)
                  .then((_) {
                scaffold.hideCurrentSnackBar();
                scaffold.showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Item added to cart',
                      textAlign: TextAlign.center,
                    ),
                    duration: Duration(seconds: 2),
                    action: SnackBarAction(
                        label: 'UNDO',
                        onPressed: () async {
                          await _cart.removeSingleItem(_product.id);
                        }),
                  ),
                );
              });
            },
            icon: Icon(Icons.shopping_cart),
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
    );
  }
}
