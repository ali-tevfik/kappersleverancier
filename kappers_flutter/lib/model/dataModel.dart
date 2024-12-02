import 'package:hive/hive.dart';

part 'dataModel.g.dart'; 

@HiveType(typeId: 0)
class Datamodel extends HiveObject {

  @HiveField(0)
  late int id;

  @HiveField(1)
  late String ean;

  @HiveField(2)
  late String name;

  @HiveField(3)
  late String imgUrl;

  @HiveField(4)
  late String price;
  
  @HiveField(5)
  late String url;

  @HiveField(6)
  int pieces =0;

  Datamodel({required this.id, required this.ean, required this.name, required this.imgUrl, required this.price, required this.url});
}
