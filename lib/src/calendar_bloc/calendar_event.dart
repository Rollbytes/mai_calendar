import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../models/index.dart';

/// 行事曆Bloc事件基類
abstract class CalendarBlocEvent {
  const CalendarBlocEvent();
}

/// 加載行事曆事件
class LoadCalendarEvents extends CalendarBlocEvent {
  final DateTime? start;
  final DateTime? end;
  final String? source;

  const LoadCalendarEvents({this.start, this.end, this.source});
}

/// 加載特定事件詳細資訊
class LoadCalendarEvent extends CalendarBlocEvent {
  final String eventId;

  const LoadCalendarEvent(this.eventId);
}

/// 創建新行事曆事件
class CreateCalendarEvent extends CalendarBlocEvent {
  final CalendarEvent calendarEvent;

  const CreateCalendarEvent(this.calendarEvent);
}

/// 更新現有行事曆事件
class UpdateCalendarEvent extends CalendarBlocEvent {
  final CalendarEvent event;

  const UpdateCalendarEvent(this.event);
}

/// 刪除行事曆事件
class DeleteCalendarEvent extends CalendarBlocEvent {
  final String eventId;

  const DeleteCalendarEvent(this.eventId);
}

/// 切換行事曆視圖
class ChangeCalendarView extends CalendarBlocEvent {
  final CalendarView view;

  const ChangeCalendarView(this.view);
}

/// 創建簡單行事曆事件
class CreateSimpleCalendarEvent extends CalendarBlocEvent {
  final String title;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isAllDay;
  final String color;

  const CreateSimpleCalendarEvent({
    required this.title,
    required this.startTime,
    this.endTime,
    this.isAllDay = false,
    this.color = '#000000',
  });
}

/// 切換農曆顯示
class ToggleLunarDate extends CalendarBlocEvent {
  final bool showLunarDate;

  const ToggleLunarDate(this.showLunarDate);
}

/// 更新行程顯示數量
class UpdateAppointmentDisplayCount extends CalendarBlocEvent {
  final int count;

  const UpdateAppointmentDisplayCount(this.count);
}

/// 加載搜尋結果到日曆
class LoadSearchResults extends CalendarBlocEvent {
  /// 搜尋結果事件列表
  final List<CalendarEvent> searchResults;
  final bool keepOriginalEvents;
  final String source;
  const LoadSearchResults({
    required this.searchResults,
    this.keepOriginalEvents = false,
    this.source = 'search',
  });
}
