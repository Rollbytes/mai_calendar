import 'package:get_it/get_it.dart';
import 'package:mai_calendar/src/repositories/supabase_data_source.dart';
import 'src/repositories/calendar_repository.dart';
import 'src/repositories/supabase_service.dart';

final GetIt getIt = GetIt.instance;

void setupRepository() {
  // 註冊 CalendarRepository 為單例
  getIt.registerLazySingleton<CalendarRepository>(() => CalendarRepository(dataSource: SupabaseDataSource()));

  // 註冊 SupabaseService 為單例
  getIt.registerLazySingleton<SupabaseService>(() => SupabaseService());
}
