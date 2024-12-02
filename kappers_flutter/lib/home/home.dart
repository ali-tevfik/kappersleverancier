import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:screenshot/screenshot.dart';
import '../model/dataModel.dart';
import 'package:kappers_flutter/home/bottomBar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();

}

class _HomeState extends State<Home> {
  List<Datamodel> datas = [];
  late Box<Datamodel> itemBox;
  final TextEditingController _controllerPrice = TextEditingController();
  final TextEditingController _controllerPieces = TextEditingController();
  double totalPrice = 0.0;
  final FocusNode _focusNode = FocusNode();
ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
   _addListener();
  }

_addListener(){
  print("add listener");
 _focusNode.addListener(_onFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
}
_removeListener(){
  print("Remove listener");
 _focusNode.removeListener(_onFocusChange);
}
  @override
  void dispose() {
   _removeListener();
    _focusNode.dispose();

    _controllerPrice.dispose();
    _controllerPieces.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    print("focus is ${_focusNode.hasFocus}");
    if (_focusNode.hasFocus) {
      RawKeyboard.instance.addListener(_handleKeyEvent);
    } else {
      RawKeyboard.instance.removeListener(_handleKeyEvent);
    }
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      String key = event.data.logicalKey.keyLabel;
      if (key == 'Enter') {
        _addNewItem(barcodeReader);
        barcodeReader = '';
      } else {
        barcodeReader += key;
      }
    }
  }

  Future<Datamodel?> queryData(String ean) async {
    try {
      itemBox = await Hive.openBox<Datamodel>('itemBox');
      var firstItem = itemBox.values.firstWhere((item) => item.ean == ean);
      return firstItem;
    } catch (e) {
      print('Error querying data: $e');
      return null;
    }
  }

  double _clearPriceText(String priceTxt) {
    String cleanedPrice = priceTxt.replaceAll(RegExp(r'[^\d,.]'), '');
    if (cleanedPrice.contains(',')) {
      cleanedPrice = cleanedPrice.replaceAll(',', '.');
    }
    double price = double.parse(cleanedPrice);
    return price;
  }

  void _updateTotalPrice() {
    totalPrice = 0;
    for (int i = 0; i < datas.length; i++) {
      totalPrice += _clearPriceText(datas[i].price) * datas[i].pieces;
    }
  }

  Future<Datamodel?> _changeItemInformation(BuildContext context, Datamodel data) async {
    String cleanedPrice = data.price.replaceAll(RegExp(r'[^\d,]'), '');
    cleanedPrice = cleanedPrice.replaceAll(',', '.');
    double price = double.parse(cleanedPrice);
    _removeListener();
    // if(_focusNode.hasFocus){
    //   print("naber amcikkk");
    //   FocusScope.of(context).requestFocus(_focusNode);
    // }else{
    //   print("naber amcikkk 2");
    // }

    var newPieces = data.pieces;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) { 
            return AlertDialog(
            title: const Text("Product information"),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Price"),
                ),
                TextField(
                  focusNode:_focusNode,
                  controller: _controllerPrice,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(hintText: data.price),
                  onChanged: (value) {},
                ),
                   Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(children: [
                      const Text("Piece"),
                   IconButton(
                    onPressed:() {
                      setState((){});
                      if(newPieces > 1) {
                        newPieces--;
                      }
                    },
                    icon: const Icon(Icons.remove_circle),),
                      Text("$newPieces"),
                      IconButton(
                        icon: const Icon(Icons.add_circle),
                        onPressed: () {
                        newPieces++;
                        setState(() {
                          
                        });
                      },),
                      ]),
                  ),
                ),
              ],
            ),
            actions: [
              
              TextButton(
                onPressed: () {
                  String newPrice = _controllerPrice.text.trim();
                  if (newPrice.isNotEmpty && newPrice != data.price) {
                    data.price = "€ $newPrice";
                    _updateTotalPrice();
                  }
                  if (newPieces != data.pieces) {
                    data.pieces = newPieces;
                    _updateTotalPrice();
                  }
          
                  setState(() {
                    _controllerPieces.clear();
                    _controllerPrice.clear();
                  });
                  _addListener();
                  Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
              TextButton(
                onPressed: () {
                  _controllerPieces.clear();
                  _controllerPrice.clear();
                  _addListener();
                  Navigator.pop(context);
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  _controllerPieces.clear();
                  _controllerPrice.clear();
                  _addListener();
                  datas.removeWhere((findData) => findData.ean == data.ean);
                  setState(() {});
                  Navigator.pop(context);
                },
                child: const Text("Delete item"),
              ),
            ],
          );
          }
        );
      },
    );
    return data;
  }

  void _addNewItem(String ean) async {
    var data = await queryData(ean);
    bool isExits = false;
    if (data != null) {
      totalPrice += _clearPriceText(data.price);
      for (int i = 0; i < datas.length; i++) {
        if (datas[i].ean == data.ean) {
          isExits = true;
          datas[i].pieces += 1;
          break;
        }
      }
      if (!isExits) {
        data.pieces = 1;
        datas.add(data);
      }
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Item doesn't find."),
        ),
      );
    }
  }

  String barcodeReader = '';
 
  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: screenshotController,
      child: Scaffold(
        extendBody: true,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Items",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              Expanded(
               
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: datas.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () async {
                          Datamodel? newDataModel = await _changeItemInformation(context, datas[index]);
                          if (newDataModel == null) {
                            datas.remove(index);
                          } else {
                            datas[index] = newDataModel;
                          }
                          setState(() {});
                        },
                        title: Text(datas[index].name),
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage("https://${datas[index].imgUrl}"),
                        ),
                        subtitle: Text(datas[index].ean),
                        trailing: Column(
                          children: [
                            Text("Adet: ${datas[index].pieces.toString()}"),
                            Text(datas[index].price),
                          ],
                        ),
                      );
                    },
                  ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomBar(
          totalPrice: totalPrice,
          addNewItem: (ean) {
            _addNewItem(ean);
          },
          deleteList: () async{
            await screenshotController.capture().then((bytes){
              if(bytes != null){
                _saveImage(bytes);
              }
            },
            ).catchError((onError){print(onError);});
      
      
      
            setState(() {
              datas.clear();
              totalPrice = 0;
            });
          },
        ),
      ),
    );
  }

}

Future<void> _saveImage(Uint8List bytes) async{
  final time = DateTime.now();
  final name = "ScreenShot$time";
  final result = await ImageGallerySaver.saveImage(bytes,name:name);
  print("result is $result");
}