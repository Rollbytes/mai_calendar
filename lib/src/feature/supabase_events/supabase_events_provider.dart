import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../calendar_bloc/calendar_bloc.dart';
import '../../repositories/calendar_repository.dart';

/// 為應用程式提供 Supabase 事件數據源
class SupabaseEventsProvider extends StatelessWidget {
  final Widget child;

  const SupabaseEventsProvider({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // 使用 getIt 獲取已註冊的 SupabaseService 實例，不再嘗試重新初始化
      future: Future.value(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // 初始化完成（這裡不再嘗試初始化，因為在 main.dart 已經初始化）
          if (snapshot.hasError) {
            // 初始化出錯，顯示錯誤信息
            return Material(
              child: Center(
                child: Text('初始化 Supabase 失敗: ${snapshot.error}'),
              ),
            );
          }

          // 直接從 getIt 獲取已初始化的 SupabaseService 和在 repository_regisitor.dart 註冊的 CalendarRepository
          final repository = Provider.of<CalendarRepository>(context, listen: false);

          // 提供 CalendarBloc
          return BlocProvider<CalendarBloc>(
            create: (context) => CalendarBloc(repository: repository),
            child: child,
          );
        }

        // 顯示加載指示器
        return const Material(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
