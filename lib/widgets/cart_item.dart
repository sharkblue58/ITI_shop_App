import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart';

class CartItemW extends StatelessWidget {
  final String id;
  final String productId;
  final String title;
  final double price;
  final int qty;

  CartItemW(this.id, this.productId, this.title, this.price, this.qty);

  @override
  Widget build(BuildContext context) {
    print(id + '_' + productId);

    return Dismissible(
      key: ValueKey(id),
      confirmDismiss: (direction) {
        return showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('Confirmation'),
                  content: Text('Remove item from cart?'),
                  actions: [
                    TextButton(onPressed: () {
                      Navigator.of(ctx).pop(false);
                    }, child: Text('No')),
                    TextButton(onPressed: () {
                      Navigator.of(ctx).pop(true);
                    }, child: Text('Yes')),
                  ],
                ));
      },
      direction: DismissDirection.endToStart,
      onDismissed: (direction) async{
        await Provider.of<Cart>(context, listen: false).removeItem(productId);
      },
      background: Container(
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 20,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
      ),
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: FittedBox(child: Text('\$$price')),
              ),
            ),
            title: Text(title),
            subtitle: Text('Total: \$${price * qty}'),
            trailing: Text('$qty x'),
          ),
        ),
      ),
    );
  }
}
