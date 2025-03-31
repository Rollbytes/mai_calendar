import '../models/index.dart';
import 'data_source.dart';
import 'local_mock_data_source.dart';

/// CalendarRepository 負責處理日曆數據的存取
class CalendarRepository {
  final DataSource _dataSource;

  /// 創建一個CalendarRepository實例
  ///
  /// [dataSource] - 可選，數據源，如果未提供將使用LocalMockDataSource
  CalendarRepository({DataSource? dataSource}) : _dataSource = dataSource ?? LocalMockDataSource();

  /// 獲取特定時間範圍內的行事曆事件
  ///
  /// [start] - 可選，開始時間
  /// [end] - 可選，結束時間
  /// [source] - 可選，事件來源過濾
  Future<List<CalendarEvent>> getEvents({
    DateTime? start,
    DateTime? end,
    String? source,
  }) {
    return _dataSource.getEvents(
      start: start,
      end: end,
      source: source,
    );
  }

  /// 獲取特定ID的行事曆事件
  ///
  /// [id] - 事件ID
  Future<CalendarEvent?> getEvent(String id) {
    return _dataSource.getEvent(id);
  }

  /// 創建新的行事曆事件
  ///
  /// [event] - 要創建的行事曆事件
  Future<CalendarEvent> createEvent(CalendarEvent event) async {
    // 嘗試獲取並設置相關的名稱信息
    if (event.baseId != null && event.baseName == null) {
      final base = await _dataSource.getBase(event.baseId!);
      if (base != null) {
        event = event.copyWith(baseName: base.name, base: base);
      }
    }

    if (event.boardId != null && event.boardName == null) {
      final board = await _dataSource.getBoard(event.boardId!);
      if (board != null) {
        event = event.copyWith(boardName: board.name, board: board);
      }
    }

    if (event.tableId != null && event.tableName == null) {
      final table = await _dataSource.getTable(event.tableId!);
      if (table != null) {
        event = event.copyWith(tableName: table.name, table: table);
      }
    }

    if (event.columnId != null && event.columnName == null) {
      final column = await _dataSource.getColumn(event.columnId!);
      if (column != null) {
        event = event.copyWith(columnName: column.name, columnOptions: column.options, column: column);
      }
    }

    if (event.rowId != null) {
      final row = await _dataSource.getRow(event.rowId!);
      if (row != null) {
        event = event.copyWith(row: row);
      }
    }

    return _dataSource.createEvent(event);
  }

  /// 更新現有的行事曆事件
  ///
  /// [event] - 要更新的行事曆事件
  Future<CalendarEvent> updateEvent(CalendarEvent event) async {
    // 嘗試獲取並設置相關的名稱信息
    if (event.baseId != null && event.baseName == null) {
      final base = await _dataSource.getBase(event.baseId!);
      if (base != null) {
        event = event.copyWith(baseName: base.name, base: base);
      }
    }

    if (event.boardId != null && event.boardName == null) {
      final board = await _dataSource.getBoard(event.boardId!);
      if (board != null) {
        event = event.copyWith(boardName: board.name, board: board);
      }
    }

    if (event.tableId != null && event.tableName == null) {
      final table = await _dataSource.getTable(event.tableId!);
      if (table != null) {
        event = event.copyWith(tableName: table.name, table: table);
      }
    }

    if (event.columnId != null && event.columnName == null) {
      final column = await _dataSource.getColumn(event.columnId!);
      if (column != null) {
        event = event.copyWith(columnName: column.name, columnOptions: column.options, column: column);
      }
    }

    if (event.rowId != null) {
      final row = await _dataSource.getRow(event.rowId!);
      if (row != null) {
        event = event.copyWith(row: row);
      }
    }

    return _dataSource.updateEvent(event);
  }

  /// 刪除行事曆事件
  ///
  /// [id] - 要刪除的事件ID
  Future<bool> deleteEvent(String id) {
    return _dataSource.deleteEvent(id);
  }

  /// 批量刪除行事曆事件
  ///
  /// [ids] - 要刪除的事件ID列表
  Future<bool> deleteEvents(List<String> ids) {
    return _dataSource.deleteEvents(ids);
  }

  /// 創建簡化版的行事曆事件
  ///
  /// [title] - 事件標題
  /// [startTime] - 開始時間
  /// [endTime] - 可選，結束時間
  /// [isAllDay] - 是否為全天事件
  /// [color] - 可選，事件顏色
  /// [baseId] - 可選，基地ID
  /// [boardId] - 可選，協作版ID
  /// [tableId] - 可選，表格ID
  /// [rowId] - 可選，行ID
  /// [columnId] - 可選，列ID
  Future<CalendarEvent> createSimpleEvent({
    required String title,
    required DateTime startTime,
    DateTime? endTime,
    bool isAllDay = false,
    String? color,
    String? baseId,
    String? boardId,
    String? tableId,
    String? rowId,
    String? columnId,
  }) async {
    final event = CalendarEvent(
      id: '', // 將由資料源生成
      title: title,
      startTime: startTime,
      endTime: endTime,
      isAllDay: isAllDay,
      color: color ?? '#3366FFFF', // 預設藍色
      source: 'MaiTable',
      baseId: baseId,
      boardId: boardId,
      tableId: tableId,
      rowId: rowId,
      columnId: columnId,
    );

    return createEvent(event);
  }

  /// 移動事件到不同的位置
  ///
  /// [eventId] - 事件ID
  /// [baseId] - 可選，新的基地ID
  /// [boardId] - 可選，新的協作版ID
  /// [tableId] - 可選，新的表格ID
  /// [rowId] - 可選，新的行ID
  /// [columnId] - 可選，新的列ID
  Future<CalendarEvent> moveEvent({
    required String eventId,
    String? baseId,
    String? boardId,
    String? tableId,
    String? rowId,
    String? columnId,
  }) async {
    final event = await _dataSource.getEvent(eventId);
    if (event == null) {
      throw Exception('Event not found: $eventId');
    }

    final updatedEvent = event.copyWith(
      baseId: baseId ?? event.baseId,
      boardId: boardId ?? event.boardId,
      tableId: tableId ?? event.tableId,
      rowId: rowId ?? event.rowId,
      columnId: columnId ?? event.columnId,
      // 清除舊的名稱，在更新時會重新獲取
      baseName: baseId != null && baseId != event.baseId ? null : event.baseName,
      boardName: boardId != null && boardId != event.boardId ? null : event.boardName,
      tableName: tableId != null && tableId != event.tableId ? null : event.tableName,
      columnName: columnId != null && columnId != event.columnId ? null : event.columnName,
    );

    return updateEvent(updatedEvent);
  }

  /// 變更事件時間
  ///
  /// [eventId] - 事件ID
  /// [startTime] - 新的開始時間
  /// [endTime] - 可選，新的結束時間
  /// [isAllDay] - 可選，是否為全天事件
  Future<CalendarEvent> changeEventTime({
    required String eventId,
    required DateTime startTime,
    DateTime? endTime,
    bool? isAllDay,
  }) async {
    final event = await _dataSource.getEvent(eventId);
    if (event == null) {
      throw Exception('Event not found: $eventId');
    }

    final updatedEvent = event.copyWith(
      startTime: startTime,
      endTime: endTime,
      isAllDay: isAllDay ?? event.isAllDay,
    );

    return updateEvent(updatedEvent);
  }
}
