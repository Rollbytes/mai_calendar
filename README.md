# Mai Calendar

Mai Calendar 是一個功能豐富的 Flutter 日曆套件，提供事件管理、日曆視圖、約會排程等功能。

## 功能

- 完整的日曆視圖
- 事件管理
- 約會排程
- 顏色選擇器
- 時間選擇器
- 空間選擇器
- Supabase 整合

## 使用方式

### 安裝

將此行添加到 pubspec.yaml 文件中的依賴項：

```yaml
dependencies:
  mai_calendar:
    path: ../packages/features/mai_calendar
```

### 基本用法

```dart
import 'package:flutter/material.dart';
import 'package:mai_calendar/main.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mai Calendar Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('Mai Calendar')),
        body: const Center(
          child: MaiCalendarWidget(),
        ),
      ),
    );
  }
}
```

## 範例

完整的範例應用程式位於 `example` 資料夾中。

## 核心模組

- **calendar_bloc**: 處理日曆資料和事件管理的 BLoC
- **widgets**: 提供各種日曆相關的 UI 元件
- **feature**: 包含特定功能，如顏色選擇器、時間選擇器等

## 許可證

MIT
