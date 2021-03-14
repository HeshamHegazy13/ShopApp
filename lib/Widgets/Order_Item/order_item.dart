import 'package:flutter/material.dart';

import './widgets/order_item_state.dart';
import '../../providers/order_provider.dart' as ord;

class OrderItem extends StatefulWidget {
  final ord.OrderItem order;
  OrderItem(this.order);

  @override
  OrderItemState createState() => OrderItemState();
}
