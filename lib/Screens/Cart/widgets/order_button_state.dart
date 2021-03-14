import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Screens/Cart/widgets/order_button.dart';
import '../../../providers/order_provider.dart';

class OrderButtonState extends State<OrderButton> {
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
