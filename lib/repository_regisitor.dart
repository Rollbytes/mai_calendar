import 'package:get_it/get_it.dart';
import 'src/repositories/calendar_repository.dart';

final GetIt getIt = GetIt.instance;

void setupRepository() {
  // 註冊 CalendarRepository 為單例
  getIt.registerLazySingleton<CalendarRepository>(() => CalendarRepository());
}
