import 'package:flutter/material.dart';
import 'screen/home_screen.dart';
import 'repository_regisitor.dart';

void main() {
  // 初始化服務定位器
  setupRepository();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mai Calendar',
      home: const HomeScreen(),
    );
  }
}
