import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'repository_regisitor.dart';
import 'screen/home_screen.dart';
import 'src/config/env_config.dart';
import 'src/feature/supabase_events/supabase_events_provider.dart';
import 'src/repositories/calendar_repository.dart';
import 'src/repositories/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化服務定位器
  setupRepository();

  // 初始化 Supabase
  await getIt<SupabaseService>().initialize(
    supabaseUrl: EnvConfig.supabaseUrl,
    supabaseKey: EnvConfig.supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<CalendarRepository>.value(
      value: getIt<CalendarRepository>(),
      child: SupabaseEventsProvider(
        child: MaterialApp(
          title: 'Mai Calendar',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
          ),
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
