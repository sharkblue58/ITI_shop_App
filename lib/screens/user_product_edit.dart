import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/products.dart';

class UserProductEdit extends StatefulWidget {
  static const routeName = '/edit-products';

  @override
  _UserProductEditState createState() => _UserProductEditState();
}

class _UserProductEditState extends State<UserProductEdit> {
  final _imageURLController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _formData = GlobalKey<FormState>();
  bool _isInit = false;
  bool _isLoading = false;

  var _editedProduct =
      Product(id: '', title: '', description: '', price: 0, imageUrl: '');

  @override
  void initState() {
    _imageUrlFocusNode.addListener(updateImagePreview);
    super.initState();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(updateImagePreview);
    _imageURLController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      final productId = ModalRoute.of(context)!.settings.arguments as String;
      if (productId != "") {
        _editedProduct = Provider.of<Products>(context, listen: false)
            .getProductById(productId);
        _imageURLController.text = _editedProduct.imageUrl;
        updateImagePreview();
      }
    }
    _isInit = true;

    super.didChangeDependencies();
  }

  void updateImagePreview() {
    String val = _imageURLController.text;

    if (!Uri.tryParse(val)!.isAbsolute) {
      print('not valid url');
      return;
    }

    if (!val.endsWith('jpg') && !val.endsWith('jepg') && !val.endsWith('png')) {
      print('not valid image url');
      return;
    }

    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  Future<void> _submitForm() async {
    final isValid = _formData.currentState!.validate();
    if (!isValid) {
      print('not valid');
      return;
    }
    _formData.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    if (_editedProduct.id != "") {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        print(error);

        await showDialog<Null>(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('An error occured'),
                  content: Text(error.toString()),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('OK'))
                  ],
                ));
      } 
      // finally {
      //   setState(() {
      //     _isLoading = false;
      //   });

      //   Navigator.of(context).pop();
      // }
    }
     setState(() {
          _isLoading = false;
        });

        Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Products'),
        actions: [
          IconButton(onPressed: () => _submitForm(), icon: Icon(Icons.save))
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15),
              child: Form(
                key: _formData,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _editedProduct.title,
                      decoration: InputDecoration(
                        labelText: 'Title',
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Title cannot be blank';
                        }

                        print(val);
                        return null;
                      },
                      onSaved: (val) {
                        _editedProduct = Product(
                            title: (val == null ? "" : val),
                            description: _editedProduct.description,
                            price: _editedProduct.price,
                            imageUrl: _editedProduct.imageUrl,
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite);
                      },
                    ),
                    TextFormField(
                      initialValue: _editedProduct.price.toString(),
                      decoration: InputDecoration(
                        labelText: 'Price',
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Price cannot be blank';
                        }

                        if (double.tryParse(val) == null) {
                          return 'Please enter a valid number';
                        }

                        if (double.parse(val) <= 0) {
                          return 'Price must be bigger than 0';
                        }

                        print(val);
                        return null;
                      },
                      onSaved: (val) {
                        _editedProduct = Product(
                            title: _editedProduct.title,
                            description: _editedProduct.description,
                            price: (val == null ? 0.0 : double.parse(val)),
                            imageUrl: _editedProduct.imageUrl,
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite);
                      },
                    ),
                    TextFormField(
                      initialValue: _editedProduct.description,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description',
                      ),
                      keyboardType: TextInputType.multiline,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Description cannot be blank';
                        }

                        print(val);
                        return null;
                      },
                      onSaved: (val) {
                        _editedProduct = Product(
                            title: _editedProduct.title,
                            description: (val == null ? "" : val),
                            price: _editedProduct.price,
                            imageUrl: _editedProduct.imageUrl,
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite);
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          child: _imageURLController.text.isEmpty
                              ? Text('Enter an URL')
                              : FittedBox(
                                  fit: BoxFit.contain,
                                  child:
                                      Image.network(_imageURLController.text),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _imageURLController,
                            focusNode: _imageUrlFocusNode,
                            decoration: InputDecoration(
                              labelText: 'Image URL',
                            ),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            validator: (val) {
                              if (val!.isEmpty) {
                                return 'Image Url cannot be blank';
                              }

                              if (!Uri.tryParse(val)!.isAbsolute) {
                                return 'Please enter a valid Url';
                              }

                              if (!val.endsWith('jpg') &&
                                  !val.endsWith('jepg') &&
                                  !val.endsWith('png')) {
                                return 'Please enter a valid Image Url';
                              }

                              print(val);
                              return null;
                            },
                            onFieldSubmitted: (val) {
                              _submitForm();
                            },
                            onEditingComplete: () {
                              setState(() {});
                            },
                            onSaved: (val) {
                              _editedProduct = Product(
                                  title: _editedProduct.title,
                                  description: _editedProduct.description,
                                  price: _editedProduct.price,
                                  imageUrl: (val == null ? "" : val),
                                  id: _editedProduct.id,
                                  isFavorite: _editedProduct.isFavorite);
                            },
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
