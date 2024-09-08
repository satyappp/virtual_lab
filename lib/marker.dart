import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'marker.g.dart';

@HiveType(typeId: 0)
class MarkerModel extends HiveObject {
  @HiveField(0)
  double dx;

  @HiveField(1)
  double dy;

  @HiveField(2)
  String name;

  @HiveField(3)
  String year;

  @HiveField(4)
  String hardware;

  @HiveField(5)
  bool isUser;

  MarkerModel({
    required this.dx,
    required this.dy,
    required this.name,
    required this.year,
    required this.hardware,
    required this.isUser,
  });

  Offset get position => Offset(dx, dy);
}
