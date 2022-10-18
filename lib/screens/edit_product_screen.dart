import 'package:flutter/material.dart';
import 'package:shop_app/providers/product.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';

class EditProductScreen extends StatefulWidget {
  @override
  State<EditProductScreen> createState() => _EditProductScreenState();

  static const routeName = '/edit-product';
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedProduct = Product(
    id: null,
    title: '',
    price: 0,
    description: '',
    imageUrl: '',
  );
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': ''
  };

  var _isInit = true;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(updateImageUrl);
    super.initState();
  }

  //After initiate focus node dispose to memory leak
  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    //called multiple times like useCallback
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          //'imageUrl': _editedProduct.imageUrl
          'imageUrl': ''
        };

        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }

    _isInit = false;
    super.didChangeDependencies();
  }

  void updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('png') &&
              !_imageUrlController.text.endsWith('jpg'))) {
        return;
      }
      setState(() {});
    }
  }

  void _saveForm() {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();

    if (_editedProduct.id == null) {
      Provider.of<Products>(context, listen: false).addProduct(_editedProduct);
    } else {
      Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: <Widget>[
          IconButton(
            onPressed: _saveForm,
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _form,
          child: ListView(
            children: <Widget>[
              TextFormField(
                initialValue: _initValues['title'],
                decoration: InputDecoration(labelText: 'Title'),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_priceFocusNode);
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please provide a value';
                  }

                  return null;
                },
                onSaved: (value) {
                  _editedProduct = Product(
                      title: value,
                      price: _editedProduct.price,
                      description: _editedProduct.description,
                      id: _editedProduct.id,
                      imageUrl: _editedProduct.imageUrl,
                      isFavorite: _editedProduct.isFavorite);
                },
              ),
              TextFormField(
                initialValue: _initValues['price'],
                decoration: InputDecoration(labelText: 'Price'),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                focusNode: _priceFocusNode,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_descriptionFocusNode);
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a price';
                  }

                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number.';
                  }

                  if (double.parse(value) <= 0) {
                    return 'Please enter a number greater than zero.';
                  }

                  return null;
                },
                onSaved: (value) {
                  _editedProduct = Product(
                      title: _editedProduct.title,
                      price: double.parse(value),
                      description: _editedProduct.description,
                      id: _editedProduct.id,
                      imageUrl: _editedProduct.imageUrl,
                      isFavorite: _editedProduct.isFavorite);
                },
              ),
              TextFormField(
                initialValue: _initValues['description'],
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                focusNode: _descriptionFocusNode,
                onSaved: (value) {
                  _editedProduct = Product(
                      title: _editedProduct.title,
                      price: _editedProduct.price,
                      description: value,
                      id: _editedProduct.id,
                      imageUrl: _editedProduct.imageUrl,
                      isFavorite: _editedProduct.isFavorite);
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a description.';
                  }

                  if (value.length < 10) {
                    return 'Should be at least 10 character long.';
                  }

                  return null;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    width: 100,
                    height: 100,
                    margin: EdgeInsets.only(top: 10, right: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.grey),
                    ),
                    child: _imageUrlController.text.isEmpty
                        ? Text("Enter a URL")
                        : FittedBox(
                            child: Image.network(_imageUrlController.text),
                            fit: BoxFit.cover,
                          ),
                  ),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Image URL',
                      ),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      controller: _imageUrlController,
                      focusNode: _imageUrlFocusNode,
                      onFieldSubmitted: (_) {
                        _saveForm();
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter an Image URL.';
                        }

                        if (!value.startsWith('http') &&
                            !value.startsWith('https')) {
                          return 'Please enter a valid URL.';
                        }

                        if (!value.endsWith('png') && !value.endsWith('jpg')) {
                          return 'Please enter a valid image URL.';
                        }

                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          title: _editedProduct.title,
                          price: _editedProduct.price,
                          description: _editedProduct.description,
                          id: _editedProduct.id,
                          imageUrl: value,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
