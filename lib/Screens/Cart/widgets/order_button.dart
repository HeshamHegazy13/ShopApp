import 'package:flutter/material.dart';

import '../../../providers/cart_provider.dart';

import './order_button_state.dart';

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.loadedCart,
  }) : super(key: key);

  final Cart loadedCart;

  @override
  OrderButtonState createState() => OrderButtonState();
}
