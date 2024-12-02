
import 'package:flutter/material.dart';
import 'package:kappers_flutter/extensions/context_extensions.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'dart:typed_data';
import 'package:screenshot/screenshot.dart';
import 'package:permission_handler/permission_handler.dart';



class BottomBar extends StatelessWidget {
  final Function(String) addNewItem;
  final Function() deleteList;
  double totalPrice = 0.0;
   BottomBar({super.key, required this.totalPrice, required this.addNewItem, required this.deleteList});
  
  Future<String> _openCamera()async{
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
                                                    "#ff6666", 
                                                    "Cancel", 
                                                    true, 
                                                    ScanMode.BARCODE);
    return barcodeScanRes;
  }

  @override
  Widget build(BuildContext context) {



    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.05)),
      child: BottomAppBar(
        surfaceTintColor: Colors.transparent,
        color: Colors.transparent,
        height: context.dynamicHeight(0.15),
        padding: context.paddingBottomHigh,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 10,
          color: Colors.pinkAccent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Text("Total price: $totalPrice"),
                 IconButton(onPressed: ()async{
                  String cameraReader = await _openCamera();
                  addNewItem(cameraReader);}
                 , icon: const Icon(Icons.camera_enhance)),
                       
                IconButton(
                  onPressed: () async {
                    deleteList();
                  },
                  icon: const Icon(Icons.clear),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
