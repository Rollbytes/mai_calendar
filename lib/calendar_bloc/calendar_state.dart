import 'package:equatable/equatable.dart';
import '../models/index.dart';

/// 行事曆Bloc狀態基類
abstract class CalendarState extends Equatable {
  const CalendarState();

  @override
  List<Object?> get props => [];
}

/// 初始狀態
class CalendarInitial extends CalendarState {}

/// 正在加載事件
class CalendarEventsLoading extends CalendarState {}

/// 事件加載成功
class CalendarEventsLoaded extends CalendarState {
  final List<CalendarEvent> events;
  final DateTime? startDate;
  final DateTime? endDate;

  const CalendarEventsLoaded({
    required this.events,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [events, startDate, endDate];
}

/// 單個事件加載成功
class CalendarEventLoaded extends CalendarState {
  final CalendarEvent event;

  const CalendarEventLoaded(this.event);

  @override
  List<Object?> get props => [event];
}

/// 事件創建成功
class CalendarEventCreated extends CalendarState {
  final CalendarEvent event;

  const CalendarEventCreated(this.event);

  @override
  List<Object?> get props => [event];
}

/// 事件更新成功
class CalendarEventUpdated extends CalendarState {
  final CalendarEvent event;

  const CalendarEventUpdated(this.event);

  @override
  List<Object?> get props => [event];
}

/// 事件刪除成功
class CalendarEventDeleted extends CalendarState {
  final String eventId;

  const CalendarEventDeleted(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

/// 多個事件刪除成功
class CalendarEventsDeleted extends CalendarState {
  final List<String> eventIds;

  const CalendarEventsDeleted(this.eventIds);

  @override
  List<Object?> get props => [eventIds];
}

/// 操作失敗
class CalendarOperationFailed extends CalendarState {
  final String message;
  final Object? error;

  const CalendarOperationFailed(this.message, [this.error]);

  @override
  List<Object?> get props => [message, error];
}
