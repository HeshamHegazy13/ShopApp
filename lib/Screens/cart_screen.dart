import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart' show Cart;
import '../providers/order_provider.dart';
import '../Widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart-screen';
  @override
  Widget build(BuildContext context) {
    final loadedCart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      '\$${loadedCart.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                          color: Theme.of(context)
                              .primaryTextTheme
                              .headline6
                              .color),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  OrderButton(loadedCart: loadedCart)
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (ctx, index) {
                return CartItem(
                    loadedCart.items.values.toList()[index].id,
                    loadedCart.items.keys.toList()[index],
                    loadedCart.items.values.toList()[index].price,
                    loadedCart.items.values.toList()[index].quantity,
                    loadedCart.items.values.toList()[index].title);
              },
              itemCount: loadedCart.itemCount,
            ),
          )
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.loadedCart,
  }) : super(key: key);

  final Cart loadedCart;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: (widget.loadedCart.itemCount <= 0 || _isLoading)
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });

              await Provider.of<Orders>(context, listen: false).addOrder(
                  widget.loadedCart.items.values.toList(),
                  widget.loadedCart.totalAmount);

              setState(() {
                _isLoading = false;
              });

              widget.loadedCart.clearCart();
            },
      child: _isLoading
          ? CircularProgressIndicator()
          : Text(
              'OrderNow!',
              style: TextStyle(
                  color: Theme.of(context).primaryColor, fontSize: 18),
            ),
    );
  }
}
