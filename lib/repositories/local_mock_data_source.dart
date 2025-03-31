import 'dart:async';
import 'dart:math';

import '../models/index.dart';
import 'data_source.dart';

/// 本地模擬數據源，用於開發和測試
class LocalMockDataSource implements DataSource {
  final Map<String, CalendarEvent> _events = {};
  final Map<String, Base> _bases = {};
  final Map<String, Board> _boards = {};
  final Map<String, MaiTable> _tables = {};
  final Map<String, MaiColumn> _columns = {};
  final Map<String, MaiRow> _rows = {};

  final Random _random = Random();

  // 用於創建模擬ID
  String _generateId() => 'mock_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(10000)}';

  // 創建一些模擬數據
  LocalMockDataSource() {
    _generateMockData();
  }

  void _generateMockData() {
    final now = DateTime.now();
    final userId = 'user_001';

    // 創建一個模擬的Base
    final baseId = 'base_001';
    final base = Base(
      id: baseId,
      name: '業務部專案',
      description: '業務部的所有協作專案',
      createdAt: now.subtract(const Duration(days: 30)),
      updatedAt: now,
      ownerId: userId,
      roles: [],
      members: [],
      contents: [],
    );
    _bases[baseId] = base;

    // 創建一個模擬的Board
    final boardId = 'board_001';
    final board = Board(
      id: boardId,
      name: '業務會議',
      description: '業務部定期會議和排程',
      createdAt: now.subtract(const Duration(days: 20)),
      updatedAt: now,
      createdBy: userId,
      members: [],
      roles: [],
    );
    _boards[boardId] = board;

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

    // 創建幾個模擬的行
    final rowTitles = ['週一例會', '專案啟動會議', '產品評審'];
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

    // 創建幾個模擬的行事曆事件
    for (int i = 0; i < 10; i++) {
      final eventId = _generateId();
      final rowId = 'row_${i % 3 + 1}'; // 使用3個不同的row
      final columnId = 'col_${(i % 2) + 2}'; // 使用col_2和col_3，col_1是標題列不存日期
      final row = _rows[rowId];
      final column = _columns[columnId];

      // 創建行事曆事件
      final event = CalendarEvent(
        id: eventId,
        title: rowTitles[i % 3], // 使用row標題作為事件標題
        startTime: now.add(Duration(days: i)),
        endTime: now.add(Duration(days: i, hours: 2)),
        isAllDay: i % 2 != 0, // 一半是全天事件
        color: '#${_randomColor()}FF', // 隨機顏色
        source: 'MaiTable',
        rowId: rowId,
        columnId: columnId,
        // 階層結構資訊
        baseId: baseId,
        baseName: base.name,
        boardId: boardId,
        boardName: board.name,
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

  // 生成隨機顏色
  String _randomColor() {
    return '${_random.nextInt(256).toRadixString(16).padLeft(2, '0')}'
        '${_random.nextInt(256).toRadixString(16).padLeft(2, '0')}'
        '${_random.nextInt(256).toRadixString(16).padLeft(2, '0')}';
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

      // 檢查來源
      if (source != null && event.source != source) {
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
}
