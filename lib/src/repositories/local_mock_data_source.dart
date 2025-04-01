import 'dart:async';
import 'dart:math';

import '../models/index.dart';
import 'data_source.dart';
import 'mai_calendar_data_source.dart';

/// 本地模擬數據源，用於開發和測試
class LocalMockDataSource implements DataSource {
  final Map<String, CalendarEvent> _events = {};
  final Map<String, Base> _bases = {};
  final Map<String, Board> _boards = {};
  final Map<String, MaiTable> _tables = {};
  final Map<String, MaiColumn> _columns = {};
  final Map<String, MaiRow> _rows = {};
  final Map<String, String> _boardToBaseMap = {};

  final Random _random = Random();

  // 用於創建模擬ID
  String _generateId() => 'mock_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(10000)}';

  // 創建一些模擬數據
  LocalMockDataSource() {
    _generateMockData();
  }

  // 使用MaiCalendarDataSource中的預設顏色列表
  Map<String, String> get _predefinedColors => MaiCalendarDataSource.predefinedColors;

  void _generateMockData() {
    final now = DateTime.now();
    final userId = 'user_001';

    // 創建幾個模擬的 Base
    final bases = [
      Base(
        id: 'base_001',
        name: '業務部專案',
        description: '業務部的所有協作專案',
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now,
        ownerId: userId,
        roles: [],
        members: [],
        contents: [],
      ),
      Base(
        id: 'base_002',
        name: '產品部專案',
        description: '產品部的所有協作專案',
        createdAt: now.subtract(const Duration(days: 25)),
        updatedAt: now,
        ownerId: userId,
        roles: [],
        members: [],
        contents: [],
      ),
      Base(
        id: 'base_003',
        name: '研發部專案',
        description: '研發部的所有協作專案',
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now,
        ownerId: userId,
        roles: [],
        members: [],
        contents: [],
      ),
    ];

    for (var base in bases) {
      _bases[base.id] = base;
    }

    // 創建多個模擬的 Board，每個 Board 關聯到特定的 Base
    final boards = [
      // 業務部 Boards
      Board(
        id: 'board_001',
        name: '業務會議',
        description: '業務部定期會議和排程',
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now,
        createdBy: userId,
        members: [],
        roles: [],
      ),
      Board(
        id: 'board_002',
        name: '客戶管理',
        description: '客戶資訊與合約管理',
        createdAt: now.subtract(const Duration(days: 18)),
        updatedAt: now,
        createdBy: userId,
        members: [],
        roles: [],
      ),
      // 產品部 Boards
      Board(
        id: 'board_003',
        name: '產品規劃',
        description: '產品路線圖與規劃',
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now,
        createdBy: userId,
        members: [],
        roles: [],
      ),
      Board(
        id: 'board_004',
        name: '需求追蹤',
        description: '用戶需求收集與追蹤',
        createdAt: now.subtract(const Duration(days: 12)),
        updatedAt: now,
        createdBy: userId,
        members: [],
        roles: [],
      ),
      // 研發部 Boards
      Board(
        id: 'board_005',
        name: '專案進度',
        description: '研發專案進度追蹤',
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now,
        createdBy: userId,
        members: [],
        roles: [],
      ),
      Board(
        id: 'board_006',
        name: '問題追蹤',
        description: 'Bug 與問題追蹤',
        createdAt: now.subtract(const Duration(days: 8)),
        updatedAt: now,
        createdBy: userId,
        members: [],
        roles: [],
      ),
    ];

    // 建立 Board 和 Base 的對應關係
    final boardBaseMapping = {
      'board_001': 'base_001', // 業務會議 -> 業務部專案
      'board_002': 'base_001', // 客戶管理 -> 業務部專案
      'board_003': 'base_002', // 產品規劃 -> 產品部專案
      'board_004': 'base_002', // 需求追蹤 -> 產品部專案
      'board_005': 'base_003', // 專案進度 -> 研發部專案
      'board_006': 'base_003', // 問題追蹤 -> 研發部專案
    };

    for (var board in boards) {
      _boards[board.id] = board;
      // 添加到 boardToBaseMap
      if (boardBaseMapping.containsKey(board.id)) {
        _boardToBaseMap[board.id] = boardBaseMapping[board.id]!;
      }
    }

    // 創建一個模擬的MaiTable
    final tableId = 'table_001';
    final table = MaiTable(
      id: tableId,
      name: '會議排程',
      description: '業務部會議排程表',
      createdAt: now.subtract(const Duration(days: 15)),
      updatedAt: now,
      columns: [],
      rows: [],
      layouts: [],
      permissions: {},
    );
    _tables[tableId] = table;

    // 創建幾個模擬的列
    final columns = [
      MaiColumn(
        id: 'col_1',
        name: '會議標題',
        type: ColumnType.title,
        isSystem: true,
        options: {},
      ),
      MaiColumn(
        id: 'col_2',
        name: '開始時間',
        type: ColumnType.datetime,
        options: {
          'includeTime': true,
          'isShowOnCalendar': true,
          'calendarTitleFormat': 'rowTitle',
        },
      ),
      MaiColumn(
        id: 'col_3',
        name: '備註',
        type: ColumnType.text,
        options: {},
      ),
    ];

    for (final column in columns) {
      _columns[column.id] = column;
    }

    // 創建更多模擬的行
    final rowTitles = ['週一例會', '專案啟動會議', '產品評審', '客戶會議', '團隊週報', '技術討論', '設計評審', '進度追蹤', '資源分配', '風險評估'];
    final rows = [];

    for (int i = 0; i < rowTitles.length; i++) {
      final rowId = 'row_${i + 1}';
      final row = MaiRow(
        id: rowId,
        createdAt: now.subtract(Duration(days: 10 - i)),
        updatedAt: now,
        createdBy: userId,
        updatedBy: userId,
        cells: [],
      );
      _rows[rowId] = row;
      rows.add(row);
    }

    // 創建更多模擬的行事曆事件
    final numberOfEvents = 30; // 增加事件數量
    for (int i = 0; i < numberOfEvents; i++) {
      final eventId = _generateId();
      final rowId = 'row_${(i % rowTitles.length) + 1}'; // 使用所有可用的row
      final columnId = 'col_${(i % 2) + 2}'; // 使用col_2和col_3
      final row = _rows[rowId];
      final column = _columns[columnId];

      // 生成隨機的開始時間（在過去30天到未來30天之間）
      final randomDays = _random.nextInt(61) - 30; // -30 到 30 天
      final randomHours = _random.nextInt(24); // 0 到 23 小時
      final randomMinutes = _random.nextInt(60); // 0 到 59 分鐘

      final startTime = now.add(Duration(
        days: randomDays,
        hours: randomHours,
        minutes: randomMinutes,
      ));

      // 隨機決定事件持續時間（30分鐘到4小時）
      final durationHours = _random.nextInt(4) + 1; // 1 到 4 小時
      final durationMinutes = _random.nextInt(60); // 0 到 59 分鐘
      final endTime = startTime.add(Duration(
        hours: durationHours,
        minutes: durationMinutes,
      ));

      // 選擇隨機的 board 和對應的 base
      final boardId = 'board_00${(i % 6) + 1}';
      final baseId = _boardToBaseMap[boardId] ?? 'base_001'; // 使用對應的 base，若沒有則使用默認值
      final board = _boards[boardId];
      final base = _bases[baseId];

      // 創建行事曆事件
      final event = CalendarEvent(
        id: eventId,
        title: rowTitles[i % rowTitles.length],
        startTime: startTime,
        endTime: endTime,
        isAllDay: _random.nextBool(), // 隨機決定是否為全天事件
        color: _randomColor(),
        rowId: rowId,
        columnId: columnId,
        // 階層結構資訊
        baseId: baseId,
        baseName: base?.name,
        boardId: boardId,
        boardName: board?.name,
        tableId: tableId,
        tableName: table.name,
        columnName: column?.name,
        columnOptions: column?.options,
        // 關聯實體
        base: base,
        board: board,
        table: table,
        column: column,
        row: row,
      );

      _events[eventId] = event;
    }
  }

  // 生成隨機顏色 - 從預設的顏色列表中取得
  String _randomColor() {
    final colorKeys = _predefinedColors.keys.toList();
    return colorKeys[_random.nextInt(colorKeys.length)];
  }

  @override
  Future<List<CalendarEvent>> getEvents({
    DateTime? start,
    DateTime? end,
    String? source,
  }) async {
    // 模擬網絡延遲
    await Future.delayed(const Duration(milliseconds: 300));

    return _events.values.where((event) {
      // 檢查時間範圍
      if (start != null && event.startTime.isBefore(start)) {
        return false;
      }
      if (end != null && (event.endTime ?? event.startTime).isAfter(end)) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Future<CalendarEvent?> getEvent(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _events[id];
  }

  @override
  Future<CalendarEvent> createEvent(CalendarEvent event) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final id = event.id.isEmpty ? _generateId() : event.id;
    final newEvent = event.copyWith(
      id: id,
      // 確保相關實體的引用
      base: event.baseId != null ? _bases[event.baseId] : null,
      board: event.boardId != null ? _boards[event.boardId] : null,
      table: event.tableId != null ? _tables[event.tableId] : null,
      column: event.columnId != null ? _columns[event.columnId] : null,
      row: event.rowId != null ? _rows[event.rowId] : null,
    );

    _events[id] = newEvent;
    return newEvent;
  }

  @override
  Future<CalendarEvent> updateEvent(CalendarEvent event) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (!_events.containsKey(event.id)) {
      throw Exception('Event not found: ${event.id}');
    }

    final updatedEvent = event.copyWith(
      // 確保相關實體的引用
      base: event.baseId != null ? _bases[event.baseId] : null,
      board: event.boardId != null ? _boards[event.boardId] : null,
      table: event.tableId != null ? _tables[event.tableId] : null,
      column: event.columnId != null ? _columns[event.columnId] : null,
      row: event.rowId != null ? _rows[event.rowId] : null,
    );

    _events[event.id] = updatedEvent;
    return updatedEvent;
  }

  @override
  Future<bool> deleteEvent(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));

    if (!_events.containsKey(id)) {
      return false;
    }

    _events.remove(id);
    return true;
  }

  @override
  Future<bool> deleteEvents(List<String> ids) async {
    await Future.delayed(const Duration(milliseconds: 200));

    bool allDeleted = true;
    for (final id in ids) {
      if (_events.containsKey(id)) {
        _events.remove(id);
      } else {
        allDeleted = false;
      }
    }

    return allDeleted;
  }

  @override
  Future<Base?> getBase(String baseId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _bases[baseId];
  }

  @override
  Future<Board?> getBoard(String boardId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _boards[boardId];
  }

  @override
  Future<MaiTable?> getTable(String tableId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _tables[tableId];
  }

  @override
  Future<MaiColumn?> getColumn(String columnId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _columns[columnId];
  }

  @override
  Future<MaiRow?> getRow(String rowId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _rows[rowId];
  }

  /// 獲取 board 到 base 的映射關係
  Map<String, String> getBoardBaseMap() {
    return Map.from(_boardToBaseMap);
  }

  /// 根據 boardId 獲取對應的 baseId
  String? getBaseIdForBoard(String boardId) {
    return _boardToBaseMap[boardId];
  }

  /// 根據 boardId 獲取對應的 Base
  Base? getBaseForBoard(String boardId) {
    final baseId = _boardToBaseMap[boardId];
    return baseId != null ? _bases[baseId] : null;
  }
}
