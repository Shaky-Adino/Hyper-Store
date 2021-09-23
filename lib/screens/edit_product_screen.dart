import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/image_upload_model.dart';
import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {

  List<Object> images = [];
  List<String> urls = [];
  File _imageFile;
  String buttonText = "Add";
  String dropdownValue = 'select category';

  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  // final _imageUrlController = TextEditingController();
  // final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedProduct = Product(
    id: null,
    category: '',
    title: '',
    price: 0,
    description: '',
    imageUrl0: null,
    imageUrl1: null,
    imageUrl2: null,
    imageUrl3: null,
  );
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
  };
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      for(var i=0;i<4;i++)
        images.add("Add Image");
      for(var i=0;i<4;i++)
        urls.add(null);
    });
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        buttonText = "Update";
        _editedProduct = Provider.of<Products>(context, listen: false).findById(productId);
        dropdownValue = _editedProduct.category;
        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
        };
        urls[0] = _editedProduct.imageUrl0;
        urls[1] = _editedProduct.imageUrl1;
        urls[2] = _editedProduct.imageUrl2;
        urls[3] = _editedProduct.imageUrl3;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveForm(BuildContext ctx) async {
    List<ImageUploadModel> img = [];
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    for(var i=0;i<4;i++){
      if(!(images[i] is ImageUploadModel) && urls[i] == null){
        await showDialog(
          context: ctx, 
          barrierDismissible: false,
          builder: (BuildContext context){
            return AlertDialog(
              title: const Text("Images missing!"),
              shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
              content: const Text("Please attach all 4 images"),
              actions: [
                TextButton(
                  onPressed: (){
                    Navigator.of(context).pop();
                  }, 
                  child: Text("OK",style: TextStyle(color: Colors.orange[700]),))
              ],
            );
          }
        );
        return;
      }
    }

    if(dropdownValue == 'select category'){
      await showDialog(
          context: ctx, 
          barrierDismissible: false,
          builder: (BuildContext context){
            return AlertDialog(
              shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
              content: const  Text("Please select the category of your product."),
              actions: [
                TextButton(
                  onPressed: (){
                    Navigator.of(context).pop();
                  }, 
                  child: Text("OK",style: TextStyle(color: Colors.orange[700]),))
              ],
            );
          }
        );
      return;
    }
    
    for(var i=0;i<4;i++){
        if(images[i] is ImageUploadModel)
          img.add(images[i]);
        else
          img.add(ImageUploadModel());
    }
    _form.currentState.save();
    _editedProduct = Product(
      category: dropdownValue,
      title: _editedProduct.title,
      price: _editedProduct.price,
      description: _editedProduct.description,
      imageUrl0: _editedProduct.imageUrl0,
      imageUrl1: _editedProduct.imageUrl1,
      imageUrl2: _editedProduct.imageUrl2,
      imageUrl3: _editedProduct.imageUrl3,
      id: _editedProduct.id,
      isFavorite: _editedProduct.isFavorite
    );
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != null) {
      await Provider.of<Products>(context, listen: false)
          .newupdateProduct(_editedProduct.id, _editedProduct, img, urls);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .newaddProduct(_editedProduct, img);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: const Text('An error occurred!'),
                shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                content: const Text('Something went wrong.'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Okay'),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                  )
                ],
              ),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // final deviceSize = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Edit Product'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.save),
              onPressed: (){_saveForm(context);},
            ),
          ],
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _form,
                  child: SingleChildScrollView(
                    child: Column(
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
                              return 'Please provide a value.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _editedProduct = Product(
                                category: _editedProduct.category,
                                title: value,
                                price: _editedProduct.price,
                                description: _editedProduct.description,
                                imageUrl0: _editedProduct.imageUrl0,
                                imageUrl1: _editedProduct.imageUrl1,
                                imageUrl2: _editedProduct.imageUrl2,
                                imageUrl3: _editedProduct.imageUrl3,
                                id: _editedProduct.id,
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
                            FocusScope.of(context)
                                .requestFocus(_descriptionFocusNode);
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter a price.';
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
                                category: _editedProduct.category,
                                title: _editedProduct.title,
                                price: double.parse(value),
                                description: _editedProduct.description,
                                imageUrl0: _editedProduct.imageUrl0,
                                imageUrl1: _editedProduct.imageUrl1,
                                imageUrl2: _editedProduct.imageUrl2,
                                imageUrl3: _editedProduct.imageUrl3,
                                id: _editedProduct.id,
                                isFavorite: _editedProduct.isFavorite);
                          },
                        ),
                        TextFormField(
                          initialValue: _initValues['description'],
                          decoration: InputDecoration(labelText: 'Description'),
                          maxLines: 3,
                          keyboardType: TextInputType.multiline,
                          focusNode: _descriptionFocusNode,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter a description.';
                            }
                            if (value.length < 10) {
                              return 'Should be at least 10 characters long.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _editedProduct = Product(
                              category: _editedProduct.category,
                              title: _editedProduct.title,
                              price: _editedProduct.price,
                              description: value,
                              imageUrl0: _editedProduct.imageUrl0,
                              imageUrl1: _editedProduct.imageUrl1,
                              imageUrl2: _editedProduct.imageUrl2,
                              imageUrl3: _editedProduct.imageUrl3,
                              id: _editedProduct.id,
                              isFavorite: _editedProduct.isFavorite,
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Text(
                            "Add images of your product",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),

                        Row(
                          children: [
                            if(images[0] is ImageUploadModel || urls[0] != null)
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minHeight: 109,
                                  minWidth: 109,
                                  maxHeight: 109,
                                  maxWidth: 109,
                                ),
                                child: Card(
                                  clipBehavior: Clip.antiAlias,
                                  child: Stack(
                                    children: <Widget>[
                                    if(urls[0] != null)
                                      CachedNetworkImage(
                                        imageUrl: urls[0],
                                        progressIndicatorBuilder: (context, url, downloadProgress) => 
                                                  Center(child: CircularProgressIndicator(value: downloadProgress.progress)),
                                        fit: BoxFit.cover,
                                        width: 300,
                                        height: 300,
                                      ),
                                    if(urls[0] == null)
                                      Image.file(
                                          (images[0] as ImageUploadModel).imageFile,
                                          width: 300,
                                          height: 300,
                                          fit: BoxFit.fill,
                                      ),
                                      Positioned(
                                        right: 5,
                                        top: 5,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            color: Colors.white,
                                          ),
                                          width: 20,
                                          height: 20,
                                        ),
                                      ),
                                      Positioned(
                                        right: 5,
                                        top: 5,
                                        child: InkWell(
                                          child: Icon(
                                            Icons.remove_circle,
                                            size: 20,
                                            color: Colors.red,
                                          ),
                                          onTap: () {
                                            setState(() {
                                              urls[0] = null;
                                              images.replaceRange(0, 1, ['Add Image']);
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if(!(images[0] is ImageUploadModel) && urls[0] == null)
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minHeight: 109,
                                  minWidth: 109,
                                  maxHeight: 109,
                                  maxWidth: 109,
                                ),
                                child: Card(
                                  child: IconButton(
                                    icon: Icon(Icons.add_a_photo),
                                    onPressed: () {
                                      _onAddImageClick(0);
                                    },
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                    leading: Icon(Icons.arrow_left, size: 35,),
                                    title: const Text(
                                      "(This image will be used as preview)",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        letterSpacing: 1,
                                        fontStyle: FontStyle.italic
                                      ),
                                    )
                                  ),
                                ),
                              ),
                          ],
                        ),

                        buildGridView(),

                        const SizedBox(height: 15),

                        Container(
                          height: 30,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: dropdownValue,
                              items: <String>['select category', 'clothing', 'electronics', 'others']
                                .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Text(value),
                                    ),
                                  );
                                }).toList(),
                              onChanged: (String newValue) {
                                setState(() {
                                  dropdownValue = newValue;
                                });
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(8)),
                              onPressed: (){
                                _saveForm(context);
                              }, 
                              child: Text("$buttonText product",style: TextStyle(fontWeight: FontWeight.bold),softWrap: false,)
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
  Widget buildGridView() {
    return GridView.count(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 3,
      childAspectRatio: 1,
      children: List.generate(images.length - 1, (index1) {
        var index = index1 + 1;
        if (images[index] is ImageUploadModel || urls[index] != null) {
          ImageUploadModel uploadModel;
          if(images[index] is ImageUploadModel)
            uploadModel = images[index];
          else
            uploadModel = ImageUploadModel();
          return Card(
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: <Widget>[
              if(urls[index] != null)
                CachedNetworkImage(
                  imageUrl: urls[index],
                  progressIndicatorBuilder: (context, url, downloadProgress) => 
                            Center(child: CircularProgressIndicator(value: downloadProgress.progress)),
                  fit: BoxFit.cover,
                  width: 300,
                  height: 300,
                ),
              if(urls[index] == null)
                Image.file(
                    uploadModel.imageFile,
                    width: 300,
                    height: 300,
                    fit: BoxFit.fill,
                  ),
                Positioned(
                  right: 5,
                  top: 5,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    width: 20,
                    height: 20,
                  ),
                ),
                Positioned(
                  right: 5,
                  top: 5,
                  child: InkWell(
                    child: Icon(
                      Icons.remove_circle,
                      size: 20,
                      color: Colors.red,
                    ),
                    onTap: () {
                      setState(() {
                        urls[index] = null;
                        images.replaceRange(index, index + 1, ['Add Image']);
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        } else {
          return Card(
            child: IconButton(
              icon: Icon(Icons.add_a_photo),
              onPressed: () {
                _onAddImageClick(index);
              },
            ),
          );
        }
      }),
    );
  }

  Future _onAddImageClick(int index) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    setState(() {
      _imageFile = File(pickedImage.path);
      getFileImage(index);
    });
  }

  void getFileImage(int index) {
      setState(() {
        ImageUploadModel imageUpload = new ImageUploadModel();
        imageUpload.isUploaded = false;
        imageUpload.uploading = false;
        imageUpload.imageFile = _imageFile;
        imageUpload.imageUrl = '';
        images.replaceRange(index, index + 1, [imageUpload]);
      });
  }
}
