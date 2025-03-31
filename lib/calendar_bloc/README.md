# Mai.today Calendar Bloc

## 概述

`calendar_bloc` 資料夾包含了用於管理行事曆事件的狀態管理系統，使用了 Flutter Bloc 庫和 Syncfusion Flutter Calendar。這個模組負責處理行事曆事件的加載、創建、更新和刪除操作，以及提供與 Syncfusion Calendar 小部件的整合。

## 結構

```
calendar_bloc/
  ├── adapters/               # 適配器，將模型轉換為第三方組件使用的格式
  │   └── calendar_event_adapter.dart
  ├── bloc/                   # Bloc 實現
  │   └── calendar_bloc.dart
  ├── event/                  # Bloc 事件定義
  │   └── calendar_event.dart
  ├── state/                  # Bloc 狀態定義
  │   └── calendar_state.dart
  └── index.dart              # 導出所有主要元素
```

## 功能

- **數據加載**：從各種數據源加載行事曆事件
- **事件創建**：創建新的行事曆事件
- **事件更新**：更新現有的行事曆事件，包括移動事件和變更時間
- **事件刪除**：刪除單個或多個行事曆事件
- **Syncfusion 整合**：與 Syncfusion Calendar 小部件的整合

## 使用方法

### 1. 設置 Bloc Provider

首先，在應用程序中設置 Bloc Provider：

```dart
BlocProvider(
  create: (context) => CalendarBloc(repository: CalendarRepository()),
  child: MyApp(),
)
```

### 2. 使用 MaiCalendarWidget

`MaiCalendarWidget` 是一個整合了 Syncfusion Calendar 和 CalendarBloc 的小部件，可以直接在 UI 中使用：

```dart
MaiCalendarWidget(
  initialView: CalendarView.month,
  showTodayButton: true,
  onEventTap: (event) {
    // 處理事件點擊
    print('Event tapped: ${event.title}');
  },
)
```

### 3. 監聽狀態變化

```dart
BlocListener<CalendarBloc, CalendarState>(
  listener: (context, state) {
    if (state is CalendarEventCreated) {
      // 事件創建成功
    } else if (state is CalendarOperationFailed) {
      // 操作失敗
    }
  },
  child: yourWidget,
)
```

### 4. 發送事件

```dart
// 加載事件
context.read<CalendarBloc>().add(LoadCalendarEvents(
  start: DateTime(2023, 1, 1),
  end: DateTime(2023, 12, 31),
));

// 創建事件
context.read<CalendarBloc>().add(CreateSimpleCalendarEvent(
  title: '會議',
  startTime: DateTime(2023, 5, 10, 10, 0),
  endTime: DateTime(2023, 5, 10, 11, 30),
  isAllDay: false,
));

// 更新事件
context.read<CalendarBloc>().add(UpdateCalendarEvent(updatedEvent));

// 刪除事件
context.read<CalendarBloc>().add(DeleteCalendarEvent('event_id'));
```

## 依賴關係

- **models**：使用了 `CalendarEvent` 模型來表示行事曆事件
- **repositories**：依賴於 `CalendarRepository` 進行數據操作
- **third-party 庫**：
  - flutter_bloc：用於狀態管理
  - equatable：用於優化狀態比較
  - syncfusion_flutter_calendar：用於行事曆 UI 展示

## 例子

查看 `widgets/calendar_screen_example.dart` 文件以獲取完整的使用示例。
