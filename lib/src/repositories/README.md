# 行事曆資料庫設計及使用說明

## 概要

本文檔描述 Mai.today 應用程式中 `CalendarRepository` 的設計及使用方法。`CalendarRepository` 負責處理行事曆相關數據的 CRUD（創建、讀取、更新、刪除）操作，主要處理 `MaiCell` 的數據，特別是 DateTime 類型欄位的值。

## 系統架構

```
CalendarRepository
├── DataSource (抽象接口)
│   ├── LocalMockDataSource (本地模擬數據)
│   └── [未來可擴展實現，如API、Firebase等]
└── 模型
    ├── MaiCell (資料格)
    ├── DateTimeValue (日期時間值)
    └── CalendarEvent (行事曆事件)
```

## 核心元件

### 1. 模型類別 (`models/calendar_models.dart`)

- **MaiCell**: 表示資料表中的單元格，存儲日期時間值
- **DateTimeValue**: 日期時間值的結構，包含標題、開始時間、結束時間等
- **CalendarEvent**: 行事曆事件的表示，用於 UI 顯示

### 2. 數據源接口 (`repositories/data_source.dart`)

定義了數據操作的抽象接口，包括:

- 獲取事件
- 獲取單元格
- 創建單元格
- 更新單元格
- 刪除單元格

### 3. 模擬數據源 (`repositories/local_mock_data_source.dart`)

實現 `DataSource` 接口，提供本地模擬數據，用於開發和測試階段

### 4. 倉庫類 (`repositories/calendar_repository.dart`)

提供應用程序與數據源的交互接口，封裝 CRUD 操作

## 主要功能

### 事件管理

- 獲取特定時間範圍內的事件 (`getEvents`)
- 創建新事件 (`createEvent`)
- 更新事件 (`updateEvent`)
- 刪除事件 (`deleteMaiCell`)

### 單元格操作

- 獲取單元格 (`getMaiCell`)
- 按行獲取單元格 (`getMaiCellsByRow`)
- 按列獲取單元格 (`getMaiCellsByColumn`)
- 創建單元格 (`createMaiCell`)
- 更新單元格 (`updateMaiCell`)
- 刪除單元格 (`deleteMaiCell`, `deleteMaiCells`)

## 使用範例

```dart
// 初始化倉庫
final repository = CalendarRepository();

// 獲取本月事件
final now = DateTime.now();
final events = await repository.getEvents(
  start: DateTime(now.year, now.month, 1),
  end: DateTime(now.year, now.month + 1, 0),
);

// 創建新事件
final newEvent = await repository.createEvent(
  rowId: 'row_123',
  columnId: 'col_456',
  dateTimeValue: DateTimeValue(
    title: '重要會議',
    startTime: DateTime(2023, 5, 15, 14, 0),
    endTime: DateTime(2023, 5, 15, 16, 0),
    color: '#FF4081FF',
  ),
);

// 更新事件
await repository.updateEvent(
  cellId: 'cell_789',
  dateTimeValue: DateTimeValue(
    title: '已更新的會議',
    startTime: DateTime(2023, 5, 15, 15, 0),
    endTime: DateTime(2023, 5, 15, 17, 0),
    color: '#3F51B5FF',
  ),
);

// 刪除事件
await repository.deleteMaiCell('cell_789');
```

## 擴展性

系統設計允許將來擴展不同的數據源實現:

1. **API 數據源**: 與後端 API 交互
2. **Firebase 數據源**: 使用 Firebase Firestore 或 Realtime Database
3. **SQLite 數據源**: 使用本地 SQLite 數據庫

只需實現 `DataSource` 接口，然後在創建 `CalendarRepository` 時注入所需的數據源實現。
