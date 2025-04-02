import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mai_calendar/main.dart';

/// 行事曆示例頁面
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  @override
  void initState() {
    super.initState();
    // 初始化語言區域設定
    initializeDateFormatting('zh_TW', null);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // App 標題
          Text(
            'Mai Calendar Demo',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          // 說明文字
          const Text(
            '這是 Mai Calendar 套件的示例應用。\n實際使用時，請參考 README.md 文件中的說明進行配置。',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // 日曆部分
          Expanded(
            child: Center(
              child: Text(
                '引用 mai_calendar 套件成功！',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
