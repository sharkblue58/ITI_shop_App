import 'package:flutter/material.dart';
import 'package:shop_app/helpers/custom_route.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/order.dart';
import 'package:shop_app/screens/carts.dart';
import 'package:shop_app/screens/orders.dart';
import 'package:shop_app/screens/product_details.dart';
import 'package:shop_app/screens/product_overview.dart';
import 'package:shop_app/screens/splash_screen.dart';
import 'package:shop_app/screens/user_product_edit.dart';
import 'package:shop_app/screens/user_products.dart';
import 'package:shop_app/screens/auth_screen.dart';
import './providers/products.dart';

import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => Auth()),
          ChangeNotifierProxyProvider<Auth, Products>(
            create: (_) => Products('', '', []),
            update: (ctx, auth, previousProductsProvider) =>
                previousProductsProvider!
                  ..updateUser(
                    auth.token,
                    auth.userId,
                  ),
          ),
           ChangeNotifierProxyProvider<Auth, Cart>(
            create: (_) => Cart('', {}),
            update: (ctx, auth, previousCart) =>
                previousCart!
                  ..updateUser(
                    auth.token,
                  ),
          ),
          ChangeNotifierProxyProvider<Auth, Order>(
            update: (BuildContext context, auth, previousOrders) => Order(
                auth.token,
                auth.userId,
                previousOrders == null ? [] : previousOrders.orders),
            create: (context) => Order("", "", []),
          ),
        ],
        child: Consumer<Auth>(
          builder: (context, auth, _) => MaterialApp(
            title: 'MyShop',
            theme: ThemeData(
                primarySwatch: Colors.purple,
                accentColor: Colors.deepOrangeAccent,
                fontFamily: 'Lato',
                pageTransitionsTheme: PageTransitionsTheme(builders: {
                  TargetPlatform.android: CustomPageTransitionBuilder(),
                  TargetPlatform.iOS: CustomPageTransitionBuilder()
                })),
            home: auth.isSignedIn
                ? ProductsOverview()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (context, loginResult) =>
                        loginResult.connectionState == ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen()),
            routes: {
              ProductsOverview.routeName: (context) => ProductsOverview(),
              ProductDetails.routeName: (context) => ProductDetails(),
              Carts.routeName: (context) => Carts(),
              Orders.routeName: (context) => Orders(),
              UserProducts.routeName: (context) => UserProducts(),
              UserProductEdit.routeName: (context) => UserProductEdit(),
            },
          ),
        ));
  }
}
