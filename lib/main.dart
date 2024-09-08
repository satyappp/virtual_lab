import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'marker.dart';
import 'login_screen.dart';
import 'home_screen.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(MarkerModelAdapter());
  await Hive.openBox<MarkerModel>('markers');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab App Prototype',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: const LoginScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
