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
  final CalendarEvent event;

  const CreateCalendarEvent(this.event);
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

class ChangeCalendarView extends CalendarBlocEvent {
  final CalendarView view;

  const ChangeCalendarView(this.view);
}

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
