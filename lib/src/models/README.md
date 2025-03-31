# Mai.today 模型結構文檔

本目錄包含 Mai.today 應用程式的數據模型定義，這些模型反映了 Mai.today 的層級結構和數據庫設計。

## 核心模型概述

Mai.today 的模型結構分為三個主要部分：

1. **基礎結構模型** (`base_models.dart`)

   - 定義基地、文件夾和協作版等層級結構
   - 包含權限和角色管理相關的模型

2. **數據庫模型** (`db_models.dart`)

   - 定義資料庫、資料表、欄位和資料列等結構
   - 包含各種欄位類型和佈局的定義

3. **行事曆模型** (`calendar_models.dart`)
   - 定義行事曆事件和日期時間值
   - 提供行事曆事件與資料表整合的功能

## 模型層級結構

Mai.today 系統採用多層級結構組織內容：

```
Base (基地)
├── Folder (文件夾)
│   ├── Sub-Folder (子文件夾)
│   └── Board (協作版)
│       ├── MaiDB (版資料庫)
│       │   └── MaiTable (資料表)
│       │       ├── MaiColumn (欄位)
│       │       └── MaiRow (資料列)
│       │           └── MaiCell (資料格)
│       └── BoardCalendar (版行事曆)
└── Board (協作版)
```

## 主要模型類別

### 基礎結構模型

- **Base**: 系統的最高層級組織單位
- **Folder**: 可嵌套的內容分類單元（最多 3 層）
- **Board**: 協作版，包含聊天室、行事曆和資料庫
- **BaseMember/BoardMember**: 成員管理
- **BaseRole/BoardRole**: 角色權限管理

### 數據庫模型

- **MaiDB**: 版內的資料庫系統
- **MaiTable**: 資料表，包含欄位和資料列
- **MaiColumn**: 表格中的欄位定義
- **MaiRow**: 表格中的資料列
- **MaiCell**: 表格中的資料格（值存儲）
- **MaiTableLayout**: 表格視圖佈局（表格、看板、行事曆等）

### 行事曆模型

- **CalendarEvent**: 行事曆事件，可來自資料表或協作版行事曆
- **DateTimeValue**: 日期時間值，用於儲存日期時間欄位的值

## 關鍵關係

- **CalendarEvent**: 整合了 Base/Board/MaiTable/MaiColumn/MaiRow 的參照，支持從多個層級獲取和顯示行事曆事件
- **MaiCell**: 存儲實際數據值，可以是多種類型（文本、數字、日期時間等）
- **MaiTableLayout**: 定義了資料表的不同視圖方式，包括行事曆視圖

## 使用示例

```dart
// 透過索引文件引入所有模型
import '../../models/models/index.dart';

// 創建和使用行事曆事件
final event = CalendarEvent(
  id: 'evt_123',
  title: '重要會議',
  startTime: DateTime.now(),
  endTime: DateTime.now().add(const Duration(hours: 2)),
  // 階層資訊
  baseId: 'base_1',
  baseName: '業務部專案',
  boardId: 'board_1',
  boardName: '業務會議',
  tableId: 'table_1',
  tableName: '會議排程',
  columnName: '開始時間',
);

// 獲取事件的位置路徑
print(event.locationPath); // 業務部專案 > 業務會議 > 會議排程

// 查看事件來源
print(event.sourceDescription); // 來自表格: 會議排程
```
