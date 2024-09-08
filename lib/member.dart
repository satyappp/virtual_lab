import 'package:hive/hive.dart';

part 'member.g.dart';

@HiveType(typeId: 1)
class Member extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String year;

  @HiveField(3)
  late String password;
}
