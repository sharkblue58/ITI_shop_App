import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/helpers/custom_route.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/screens/carts.dart';
import 'package:shop_app/screens/orders.dart';
import 'package:shop_app/screens/user_products.dart';

class MainDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    Widget buildListTile(IconData icon, String label, Function onTapHandler){
      return ListTile(
        leading: Icon(icon),
        title: Text(label),
        onTap: () => onTapHandler(),
      );
    }

    return Drawer(
        child: Column(
          children: [
            AppBar(
              title: Text('Menu'),
              automaticallyImplyLeading: false,
            ),
            Expanded(
              child: ListView(
                children: [
                  buildListTile(
                  Icons.home,
                  'Home',
                  () {
                    Navigator.of(context).pushNamed('/');
                  }
                ),
                Divider(),
                  buildListTile(
                  Icons.shopping_cart,
                  'Cart',
                  () {
                    Navigator.of(context).pushNamed(Carts.routeName);
                  }
                ),
                Divider(),
                buildListTile(
                  Icons.payment,
                  'Orders',
                  () {
                    // Navigator.of(context).pushNamed(Orders.routeName);
                     Navigator.of(context).pushReplacement(CustomRoute(builder: (ctx) => Orders(),));
                  }
                ),
                Divider(),
                buildListTile(
                  Icons.edit,
                  'Products',
                  () {
                    Navigator.of(context).pushReplacementNamed(UserProducts.routeName);
                  }
                ),
                Divider(),
                buildListTile(
                  Icons.exit_to_app,
                  'Logout',
                  () {
                    Navigator.of(context).pop();
                     Navigator.of(context).pushReplacementNamed('/');
                    Provider.of<Auth>(context,listen: false).logout();
                  }
                ),
              ],),
            ),
          ],
        ),
      );
  }
}