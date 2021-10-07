import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/user_product_edit.dart';

class UserProductItem extends StatelessWidget {
  final Product _product;

  UserProductItem(this._product);

   showAlertDialog(BuildContext ctx) {
     final scaffold = ScaffoldMessenger.of(ctx);
    AlertDialog alert = AlertDialog(
      title: Text("AlertDialog"),
      content: Text("Delete Selected Product?"),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('Cancel')),
        TextButton(
            onPressed: () async{
              Navigator.of(ctx).pop();
              try
              {
              await Provider.of<Products>(ctx, listen: false)
                  .deleteProduct(_product.id).then((_) {
                  });
              }
              catch (ex)
              {
                scaffold.showSnackBar(
                  SnackBar(content: Text(ex.toString()))
                );
              }
            },
            child: Text('Yes')),
      ],
    );

    showDialog(
    context: ctx,
    builder: (BuildContext context) {
      return alert;
    },
  );

  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(_product.title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(_product.imageUrl),
      ),
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(UserProductEdit.routeName,
                    arguments: _product.id);
              },
              icon: Icon(Icons.edit),
              color: Theme.of(context).primaryColor,
            ),
            IconButton(
              onPressed: () {
                showAlertDialog(context);
              },
              icon: Icon(Icons.delete),
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
