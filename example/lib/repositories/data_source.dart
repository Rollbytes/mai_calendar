import '../models/index.dart';

/// 數據源抽象類
abstract class DataSource {
  /// 獲取所有行事曆事件
  Future<List<CalendarEvent>> getEvents({
    DateTime? start,
    DateTime? end,
    String? source,
  });

  /// 獲取單個行事曆事件
  Future<CalendarEvent?> getEvent(String id);

  /// 創建新的行事曆事件
  Future<CalendarEvent> createEvent(CalendarEvent event);

  /// 更新現有的行事曆事件
  Future<CalendarEvent> updateEvent(CalendarEvent event);

  /// 刪除行事曆事件
  Future<bool> deleteEvent(String id);

  /// 批量刪除行事曆事件
  Future<bool> deleteEvents(List<String> ids);

  /// 獲取Base信息
  Future<Base?> getBase(String baseId);

  /// 獲取Board信息
  Future<Board?> getBoard(String boardId);

  /// 獲取MaiTable信息
  Future<MaiTable?> getTable(String tableId);

  /// 獲取MaiColumn信息
  Future<MaiColumn?> getColumn(String columnId);

  /// 獲取MaiRow信息
  Future<MaiRow?> getRow(String rowId);
}
