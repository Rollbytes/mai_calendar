import '../models/index.dart';
import 'data_source.dart';
import 'supabase_service.dart';

/// Supabase 數據源實現
class SupabaseDataSource implements DataSource {
  final SupabaseService _supabaseService;

  SupabaseDataSource({SupabaseService? supabaseService}) : _supabaseService = supabaseService ?? SupabaseService();

  @override
  Future<List<CalendarEvent>> getEvents({
    DateTime? start,
    DateTime? end,
    String? source,
  }) async {
    try {
      // 獲取 events 表中的數據
      final query = _supabaseService.client.from('events').select();

      // 創建過濾器變量
      var filtered = query;

      // 添加日期範圍過濾
      if (start != null) {
        filtered = filtered.gte('start_time', start.toIso8601String());
      }
      if (end != null) {
        filtered = filtered.lte('start_time', end.toIso8601String());
      }

      // 執行查詢
      final response = await filtered.order('start_time');

      // 將 Supabase 返回的數據轉換為 CalendarEvent 列表
      return response.map((data) => _mapToCalendarEvent(data)).toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching events: $e');
      return [];
    }
  }

  @override
  Future<CalendarEvent?> getEvent(String id) async {
    try {
      final response = await _supabaseService.client.from('events').select().eq('id', id).single();

      // 不需要檢查 response != null，因為 single() 方法要麼返回結果要麼拋出異常
      return _mapToCalendarEvent(response);
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching event: $e');
      return null;
    }
  }

  @override
  Future<CalendarEvent> createEvent(CalendarEvent event) async {
    try {
      // 映射為 Supabase 表結構
      final eventData = _mapEventToSupabase(event);

      // 插入數據並返回結果
      final response = await _supabaseService.client.from('events').insert(eventData).select().single();

      return _mapToCalendarEvent(response);
    } catch (e) {
      // ignore: avoid_print
      print('Error creating event: $e');
      throw Exception('Failed to create event: $e');
    }
  }

  @override
  Future<CalendarEvent> updateEvent(CalendarEvent event) async {
    try {
      // 映射為 Supabase 表結構
      final eventData = _mapEventToSupabase(event);

      // 更新數據並返回結果
      final response = await _supabaseService.client.from('events').update(eventData).eq('id', event.id).select().single();

      return _mapToCalendarEvent(response);
    } catch (e) {
      // ignore: avoid_print
      print('Error updating event: $e');
      throw Exception('Failed to update event: $e');
    }
  }

  @override
  Future<bool> deleteEvent(String id) async {
    try {
      await _supabaseService.client.from('events').delete().eq('id', id);
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Error deleting event: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteEvents(List<String> ids) async {
    try {
      // 由於 Supabase Flutter SDK 可能沒有直接的 inFilter 方法，
      // 這裡使用更安全的方法依次刪除
      for (final id in ids) {
        await _supabaseService.client.from('events').delete().eq('id', id);
      }
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Error deleting events: $e');
      return false;
    }
  }

  // 以下方法需要實現，但由於 Supabase 目前沒有對應的結構，暫時返回 null
  @override
  Future<Base?> getBase(String baseId) async => null;

  @override
  Future<Board?> getBoard(String boardId) async => null;

  @override
  Future<MaiTable?> getTable(String tableId) async => null;

  @override
  Future<MaiColumn?> getColumn(String columnId) async => null;

  @override
  Future<MaiRow?> getRow(String rowId) async => null;

  // 私有方法：將 Supabase 返回的數據映射為 CalendarEvent
  CalendarEvent _mapToCalendarEvent(Map<String, dynamic> data) {
    return CalendarEvent(
      id: data['id'],
      title: data['title'],
      startTime: DateTime.parse(data['start_time']),
      endTime: data['end_time'] != null ? DateTime.parse(data['end_time']) : null,
      isAllDay: data['is_all_day'] ?? false,
      color: data['color'] ?? "#FF4081FF",
      notes: data['description'] ?? "",
      locationPath: data['location_path'] ?? "",
    );
  }

  // 私有方法：將 CalendarEvent 映射為 Supabase 表結構
  Map<String, dynamic> _mapEventToSupabase(CalendarEvent event) {
    return {
      if (event.id.isNotEmpty && !event.id.startsWith('temp')) 'id': event.id,
      'title': event.title,
      'start_time': event.startTime.toIso8601String(),
      'end_time': event.endTime?.toIso8601String(),
      'is_all_day': event.isAllDay,
      'color': event.color,
      'description': event.notes,
      'location_path': event.locationPath,
      // 關聯到用戶（如果已登入）
      if (_supabaseService.client.auth.currentUser != null) 'user_id': _supabaseService.client.auth.currentUser!.id,
    };
  }
}
