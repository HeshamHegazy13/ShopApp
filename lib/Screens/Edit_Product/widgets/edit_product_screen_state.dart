import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../edit_product_screen.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/products_provider.dart';

class EditProductScreenState extends State<EditProductScreen> {
  final _pricedFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editetproduct =
      Product(id: null, title: '', description: '', price: 0, imageUrl: '');

  var isInit = true;
  var _initValus = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': ''
  };
  var _isloading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updataImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (isInit) {
      final productid = ModalRoute.of(context).settings.arguments as String;
      if (productid != null) {
        _editetproduct =
            Provider.of<Products>(context, listen: false).findById(productid);
        _initValus = {
          'title': _editetproduct.title,
          'price': _editetproduct.price.toString(),
          'description': _editetproduct.description,
          // 'imageUrl': _editetproduct.imageUrl
        };
        _imageUrlController.text = _editetproduct.imageUrl;
      }
    }
    isInit = false;

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updataImageUrl);
    _pricedFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updataImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    if (!_form.currentState.validate()) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isloading = true;
    });
    if (_editetproduct.id != null) {
      Provider.of<Products>(context, listen: false)
          .updateProduct(_editetproduct.id, _editetproduct);
      setState(() {
        _isloading = false;
        Navigator.of(context).pop();
      });
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editetproduct);
      } catch (onError) {
        await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text(onError.toString()),
                actions: [
                  FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Ok'))
                ],
              );
            });
      } finally {
        setState(() {
          _isloading = false;
          Navigator.of(context).pop();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(icon: Icon(Icons.save), onPressed: _saveForm),
        ],
        title: Text(
          'Edit Product',
        ),
      ),
      body: _isloading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                  key: _form,
                  child: ListView(
                    children: [
                      TextFormField(
                        initialValue: _initValus['title'],
                        decoration: InputDecoration(labelText: 'Title'),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).requestFocus(_pricedFocusNode);
                        },
                        onSaved: (newValue) {
                          _editetproduct = Product(
                              id: _editetproduct.id,
                              title: newValue,
                              description: _editetproduct.description,
                              price: _editetproduct.price,
                              imageUrl: _editetproduct.imageUrl,
                              isFavorite: _editetproduct.isFavorite);
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Ektb 7ga yabnl 3rs';
                          } else {
                            return null;
                          }
                        },
                      ),
                      TextFormField(
                        initialValue: _initValus['price'],
                        decoration: InputDecoration(labelText: 'Price'),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        focusNode: _pricedFocusNode,
                        onFieldSubmitted: (value) {
                          FocusScope.of(context)
                              .requestFocus(_descriptionFocusNode);
                        },
                        onSaved: (newValue) {
                          _editetproduct = Product(
                              id: _editetproduct.id,
                              title: _editetproduct.title,
                              description: _editetproduct.description,
                              price: double.parse(newValue),
                              imageUrl: _editetproduct.imageUrl,
                              isFavorite: _editetproduct.isFavorite);
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'el s3r y 3rs';
                          } else if (double.tryParse(value) == null) {
                            return 'l s3r bayz';
                          } else if (double.parse(value) <= 0) {
                            return 'enta shayf kda';
                          } else {
                            return null;
                          }
                        },
                      ),
                      TextFormField(
                          initialValue: _initValus['description'],
                          decoration: InputDecoration(labelText: 'Description'),
                          maxLines: 3,
                          keyboardType: TextInputType.multiline,
                          focusNode: _descriptionFocusNode,
                          onSaved: (newValue) {
                            _editetproduct = Product(
                                id: _editetproduct.id,
                                title: _editetproduct.title,
                                description: newValue,
                                price: _editetproduct.price,
                                imageUrl: _editetproduct.imageUrl,
                                isFavorite: _editetproduct.isFavorite);
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'ya reet nktb ya beh';
                            } else if (value.length < 10) {
                              return 'description da ';
                            } else {
                              return null;
                            }
                          }),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            height: 100,
                            width: 100,
                            margin: EdgeInsets.only(top: 8, right: 10),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.grey)),
                            child: _imageUrlController.text.isEmpty
                                ? Text('Enter URL')
                                : FittedBox(
                                    fit: BoxFit.cover,
                                    child:
                                        Image.network(_imageUrlController.text),
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                                decoration:
                                    InputDecoration(labelText: 'Image URL'),
                                keyboardType: TextInputType.url,
                                textInputAction: TextInputAction.done,
                                controller: _imageUrlController,
                                focusNode: _imageUrlFocusNode,
                                onFieldSubmitted: (value) {
                                  _saveForm();
                                },
                                onSaved: (newValue) {
                                  _editetproduct = Product(
                                      id: _editetproduct.id,
                                      title: _editetproduct.title,
                                      description: _editetproduct.description,
                                      price: _editetproduct.price,
                                      imageUrl: newValue,
                                      isFavorite: _editetproduct.isFavorite);
                                },
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'el sore fen';
                                  } else {
                                    return null;
                                  }
                                }),
                          ),
                        ],
                      )
                    ],
                  )),
            ),
    );
  }
}
