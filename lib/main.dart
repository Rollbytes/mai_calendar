import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'src/calendar_bloc/calendar_bloc.dart';
import 'src/repositories/calendar_repository.dart';
import 'screen/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 創建 CalendarRepository
    final calendarRepository = CalendarRepository();

    return MultiBlocProvider(
      providers: [
        BlocProvider<CalendarBloc>(
          create: (context) => CalendarBloc(repository: calendarRepository),
        ),
      ],
      child: MaterialApp(
        title: 'Mai Calendar',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
