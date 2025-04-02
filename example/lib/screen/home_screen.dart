import 'package:flutter/material.dart';
import 'calendar_screen.dart';

/// 範例應用的首頁
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mai Calendar Demo'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: const CalendarScreen(),
    );
  }
}
