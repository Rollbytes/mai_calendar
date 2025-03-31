import 'package:equatable/equatable.dart';
import '../models/index.dart';

/// 行事曆Bloc事件基類
abstract class CalendarBlocEvent extends Equatable {
  const CalendarBlocEvent();

  @override
  List<Object?> get props => [];
}

/// 加載行事曆事件
class LoadCalendarEvents extends CalendarBlocEvent {
  final DateTime? start;
  final DateTime? end;
  final String? source;

  const LoadCalendarEvents({this.start, this.end, this.source});

  @override
  List<Object?> get props => [start, end, source];
}

/// 加載特定事件詳細資訊
class LoadCalendarEvent extends CalendarBlocEvent {
  final String eventId;

  const LoadCalendarEvent(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

/// 創建新行事曆事件
class CreateCalendarEvent extends CalendarBlocEvent {
  final CalendarEvent event;

  const CreateCalendarEvent(this.event);

  @override
  List<Object?> get props => [event];
}

/// 創建簡化版的行事曆事件
class CreateSimpleCalendarEvent extends CalendarBlocEvent {
  final String title;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isAllDay;
  final String? color;
  final String? baseId;
  final String? boardId;
  final String? tableId;
  final String? rowId;
  final String? columnId;

  const CreateSimpleCalendarEvent({
    required this.title,
    required this.startTime,
    this.endTime,
    this.isAllDay = false,
    this.color,
    this.baseId,
    this.boardId,
    this.tableId,
    this.rowId,
    this.columnId,
  });

  @override
  List<Object?> get props => [
        title,
        startTime,
        endTime,
        isAllDay,
        color,
        baseId,
        boardId,
        tableId,
        rowId,
        columnId,
      ];
}

/// 更新現有行事曆事件
class UpdateCalendarEvent extends CalendarBlocEvent {
  final CalendarEvent event;

  const UpdateCalendarEvent(this.event);

  @override
  List<Object?> get props => [event];
}

/// 移動事件到不同位置
class MoveCalendarEvent extends CalendarBlocEvent {
  final String eventId;
  final String? baseId;
  final String? boardId;
  final String? tableId;
  final String? rowId;
  final String? columnId;

  const MoveCalendarEvent({
    required this.eventId,
    this.baseId,
    this.boardId,
    this.tableId,
    this.rowId,
    this.columnId,
  });

  @override
  List<Object?> get props => [eventId, baseId, boardId, tableId, rowId, columnId];
}

/// 變更事件時間
class ChangeCalendarEventTime extends CalendarBlocEvent {
  final String eventId;
  final DateTime startTime;
  final DateTime? endTime;
  final bool? isAllDay;

  const ChangeCalendarEventTime({
    required this.eventId,
    required this.startTime,
    this.endTime,
    this.isAllDay,
  });

  @override
  List<Object?> get props => [eventId, startTime, endTime, isAllDay];
}

/// 刪除行事曆事件
class DeleteCalendarEvent extends CalendarBlocEvent {
  final String eventId;

  const DeleteCalendarEvent(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

/// 批量刪除行事曆事件
class DeleteCalendarEvents extends CalendarBlocEvent {
  final List<String> eventIds;

  const DeleteCalendarEvents(this.eventIds);

  @override
  List<Object?> get props => [eventIds];
}
