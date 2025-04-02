import 'package:get_it/get_it.dart';
import 'package:mai_calendar/src/repositories/calendar_repository.dart';
import 'package:mai_calendar/src/repositories/data_source.dart';
import 'package:mai_calendar/src/models/index.dart';
import 'repositories/supabase_service.dart';

final GetIt getIt = GetIt.instance;

// 簡化的做法：直接關聯套件的 CalendarRepository，不使用數據源
void setupRepository() {
  // 註冊 CalendarRepository 為單例
  getIt.registerLazySingleton<CalendarRepository>(() => CalendarRepository());

  // 註冊 SupabaseService 為單例
  getIt.registerLazySingleton<SupabaseService>(() => SupabaseService());
}
