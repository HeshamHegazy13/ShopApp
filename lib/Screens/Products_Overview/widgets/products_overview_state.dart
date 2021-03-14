import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../products_overview_screen.dart';
import '../../Cart/cart_screen.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/products_provider.dart';
import '../../../Widgets/products_grid.dart';
import '../../../Widgets/badge.dart';
import '../../../Widgets/app_drawer.dart';

enum FilterOptions { Favorites, All }

class ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnlyFavorites = false;
  var _isLoading = false;
  var _isInit = true;

  @override
  void initState() {
    if (_isInit) {
      _isInit = false;
      _isLoading = true;
      Provider.of<Products>(context, listen: false)
          .fetchAndSetProducts()
          .then((value) {
        setState(() {
          _isLoading = false;
        });
      });
      super.initState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyShop'),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                print('$selectedValue');
                if (selectedValue == FilterOptions.Favorites) {
                  _showOnlyFavorites = true;
                } else if (selectedValue == FilterOptions.All) {
                  _showOnlyFavorites = false;
                }
              });
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                  child: Text('Only Favorites'),
                  value: FilterOptions.Favorites),
              PopupMenuItem(child: Text('Show All'), value: FilterOptions.All),
            ],
            icon: Icon(Icons.more_vert),
          ),
          Consumer<Cart>(
            child: IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).pushNamed(CartScreen.routeName);
                }),
            builder: (context, loadedCart, ch) => Badge(
              value: loadedCart.itemCount.toString(),
              child: ch,
            ),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(_showOnlyFavorites),
    );
  }
}
