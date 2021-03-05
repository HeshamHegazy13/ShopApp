import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './Screens/products_overview_screen.dart';
import './Screens/product_detail_screen.dart';
import './Screens/orders_screen.dart';
import './Screens/cart_screen.dart';
import './Screens/auth_screen.dart';
import './Screens/splash_screen.dart';
import './Screens/user_products_screen.dart';
import 'Screens/edit_product_screen.dart';
import './providers/cart_provider.dart';
import './providers/products_provider.dart';
import './providers/order_provider.dart';
import './providers/auth_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => Auth()),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (ctx) => null,
          update: (ctx, auth, previousProducts) => Products(
              auth.token,
              auth.userId,
              previousProducts == null ? [] : previousProducts.items),
        ),
        ChangeNotifierProvider(create: (ctx) => Cart()),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (ctx) => null,
          update: (context, auth, previousOrders) => Orders(
            auth.token,
            auth.userId,
            previousOrders != null ? previousOrders.orders : [],
          ),
        ),
      ],
      //main.dart ,, lw fi 7etta tanya .value a7sn
      child: Consumer<Auth>(
        builder: (context, auth, child) => MaterialApp(
          title: 'MyShop',
          theme: ThemeData(
            fontFamily: 'Lato',
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
          ),
          home: auth.isAuth
              ? ProductsOverviewScreen()
              : FutureBuilder(
                  builder: (ctx, snapShot) =>
                      snapShot.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                  future: auth.tryAutoLogin(),
                ),
          routes: {
            ProdcutDetailScreen.routeName: (ctx) => ProdcutDetailScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
            ProductsOverviewScreen.routeName: (ctx) => ProductsOverviewScreen(),
            AuthScreen.routeName: (ctx) => AuthScreen(),
          },
        ),
      ),
    );
  }
}
