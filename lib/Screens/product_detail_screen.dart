import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';

class ProdcutDetailScreen extends StatelessWidget {
  // final String title;
  // final double price;
  // ProdcutDetailScreen(this.title);
  static const routeName = '/product-detail-screen';

  @override
  Widget build(BuildContext context) {
    final String id = ModalRoute.of(context).settings.arguments as String;

    // final productsData = Provider.of<Products>(context);
    // final products = productsData.items;

    // int i = products.indexWhere((product) => product.id == id);

    final loadedProduct = Provider.of<Products>(
      context,
      listen: false,
    ).findById(id);

    return Scaffold(
      appBar: AppBar(title: Text('${loadedProduct.title}')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 300,
              width: double.infinity,
              child: Image.network(
                loadedProduct.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              '\$${loadedProduct.price}',
              style: TextStyle(color: Colors.green, fontSize: 20),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                loadedProduct.description,
                textAlign: TextAlign.center,
                softWrap: true,
                style: TextStyle(fontSize: 30),
              ),
            )
          ],
        ),
      ),
    );
  }
}
