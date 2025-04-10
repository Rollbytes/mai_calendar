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
    // 不再嘗試獲取和設置不存在的屬性
    return _dataSource.createEvent(event);
  }

  /// 更新現有的行事曆事件
  ///
  /// [event] - 要更新的行事曆事件
  Future<CalendarEvent> updateEvent(CalendarEvent event) async {
    // 不再嘗試獲取和設置不存在的屬性
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
  Future<CalendarEvent> createCalendarEvent({
    required String title,
    required DateTime startTime,
    DateTime? endTime,
    bool isAllDay = false,
    String? color,
  }) async {
    final event = CalendarEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // 生成臨時ID
      title: title,
      startTime: startTime,
      endTime: endTime ?? startTime.add(const Duration(hours: 1)),
      isAllDay: isAllDay,
      color: color ?? "#3366FFFF", // 預設藍色
    );

    return createEvent(event);
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

  /// 根據 Board ID 獲取對應的 Base
  ///
  /// [boardId] - Board ID
  Future<Base?> getBaseForBoard(String boardId) async {
    if (_dataSource is LocalMockDataSource) {
      final localDataSource = _dataSource as LocalMockDataSource;

      // 先嘗試通過 LocalMockDataSource 獲取 baseId
      String? baseId = localDataSource.getBaseIdForBoard(boardId);

      // 如果獲取到 baseId，則通過 baseId 獲取 Base 對象
      if (baseId != null) {
        return localDataSource.getBase(baseId);
      }

      // 如果找不到映射關係，則直接嘗試獲取 Base 對象
      return localDataSource.getBaseForBoard(boardId);
    }

    // 如果不是 LocalMockDataSource，則實現實際的獲取邏輯
    // TODO: 需要實現實際的 API 調用邏輯
    return Future.value(null);
  }

  /// 獲取所有 Board 到 Base 的映射關係
  ///
  /// 返回一個 Map<String, String>，其中 key 是 boardId，value 是 baseId
  Future<Map<String, String>> getBoardBaseMap() {
    if (_dataSource is LocalMockDataSource) {
      final localDataSource = _dataSource as LocalMockDataSource;
      return Future.value(localDataSource.getBoardBaseMap());
    }

    // 如果不是 LocalMockDataSource，則實現實際的獲取邏輯
    return Future.value({});
  }

  /// 獲取特定 Base
  ///
  /// [baseId] - Base ID
  Future<Base?> getBase(String baseId) async {
    return _dataSource.getBase(baseId);
  }

  /// 獲取特定 Board
  ///
  /// [boardId] - Board ID
  Future<Board?> getBoard(String boardId) async {
    return _dataSource.getBoard(boardId);
  }
}
