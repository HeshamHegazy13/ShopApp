import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/order_provider.dart' show Orders;
import '../Widgets/order_item.dart';
import '../Widgets/app_drawer.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders-screen';

  @override
  Widget build(BuildContext context) {
    // final orderData = Provider.of<Orders>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Your Orders'),
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
            builder: (conext, dataSnapshot) {
              if (dataSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                if (dataSnapshot.error != null) {
                  return Text('Error ${dataSnapshot.error}');
                } else {
                  return Consumer<Orders>(
                    builder: (context, orderData, child) {
                      return ListView.builder(
                        itemBuilder: (ctx, index) {
                          return OrderItem(orderData.orders[index]);
                        },
                        itemCount: orderData.orders.length,
                      );
                    },
                  );
                }
              }
            },
            future: Provider.of<Orders>(context, listen: false)
                .fetchAndSetOrders()));
  }
}
