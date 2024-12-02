import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'dart:convert';

import 'model/dataModel.dart'; // DataModel sınıfınızın olduğu dosya
import 'package:kappers_flutter/home/home.dart'; // Home widget'ınızın olduğu dosya


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(DatamodelAdapter());
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Box<Datamodel> itemBox;

  @override
  void initState() {
    super.initState();
    openBox();
  }

  Future<void> openBox() async {
    itemBox = await Hive.openBox<Datamodel>('itemBox');
    await loadCsvData();
    setState(() {});
    print("itembox size in main ${itemBox.length}");
  }

  Future<void> loadCsvData() async {
    final directory = await getApplicationDocumentsDirectory();
    var csvData = await rootBundle.loadString("assets/producten.csv");

    List<List<dynamic>> fields = const CsvToListConverter().convert(csvData);

    for (var i = 0; i < fields.length; i++) {
      final row = fields[i];

      final item = Datamodel(
        id: i,
        ean: row[0].toString(),
        name: row[1],
        price: row[2],
        url: row[3],
        imgUrl: row[4]
      );

      await itemBox.put(item.ean, item);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Home(),
    );
  }
}
