import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/calendar_repository.dart';
import 'calendar_event.dart';
import 'calendar_state.dart';

/// 行事曆Bloc
class CalendarBloc extends Bloc<CalendarBlocEvent, CalendarState> {
  final CalendarRepository _repository;

  CalendarBloc({required CalendarRepository repository})
      : _repository = repository,
        super(CalendarInitial()) {
    // 註冊事件處理
    on<LoadCalendarEvents>(_onLoadCalendarEvents);
    on<LoadCalendarEvent>(_onLoadCalendarEvent);
    on<CreateCalendarEvent>(_onCreateCalendarEvent);
    on<CreateSimpleCalendarEvent>(_onCreateSimpleCalendarEvent);
    on<UpdateCalendarEvent>(_onUpdateCalendarEvent);
    on<MoveCalendarEvent>(_onMoveCalendarEvent);
    on<ChangeCalendarEventTime>(_onChangeCalendarEventTime);
    on<DeleteCalendarEvent>(_onDeleteCalendarEvent);
    on<DeleteCalendarEvents>(_onDeleteCalendarEvents);
  }

  /// 處理加載多個事件的事件
  Future<void> _onLoadCalendarEvents(
    LoadCalendarEvents event,
    Emitter<CalendarState> emit,
  ) async {
    try {
      emit(CalendarEventsLoading());
      final events = await _repository.getEvents(
        start: event.start,
        end: event.end,
        source: event.source,
      );
      emit(CalendarEventsLoaded(
        events: events,
        startDate: event.start,
        endDate: event.end,
      ));
    } catch (e) {
      emit(CalendarOperationFailed('加載事件失敗', e));
    }
  }

  /// 處理加載單個事件的事件
  Future<void> _onLoadCalendarEvent(
    LoadCalendarEvent event,
    Emitter<CalendarState> emit,
  ) async {
    try {
      emit(CalendarEventsLoading());
      final calendarEvent = await _repository.getEvent(event.eventId);
      if (calendarEvent != null) {
        emit(CalendarEventLoaded(calendarEvent));
      } else {
        emit(const CalendarOperationFailed('事件不存在'));
      }
    } catch (e) {
      emit(CalendarOperationFailed('加載事件失敗', e));
    }
  }

  /// 處理創建事件的事件
  Future<void> _onCreateCalendarEvent(
    CreateCalendarEvent event,
    Emitter<CalendarState> emit,
  ) async {
    try {
      emit(CalendarEventsLoading());
      final createdEvent = await _repository.createEvent(event.event);
      emit(CalendarEventCreated(createdEvent));

      // 刷新事件列表
      add(LoadCalendarEvents());
    } catch (e) {
      emit(CalendarOperationFailed('創建事件失敗', e));
    }
  }

  /// 處理創建簡化事件的事件
  Future<void> _onCreateSimpleCalendarEvent(
    CreateSimpleCalendarEvent event,
    Emitter<CalendarState> emit,
  ) async {
    try {
      emit(CalendarEventsLoading());
      final createdEvent = await _repository.createSimpleEvent(
        title: event.title,
        startTime: event.startTime,
        endTime: event.endTime,
        isAllDay: event.isAllDay,
        color: event.color,
        baseId: event.baseId,
        boardId: event.boardId,
        tableId: event.tableId,
        rowId: event.rowId,
        columnId: event.columnId,
      );
      emit(CalendarEventCreated(createdEvent));

      // 刷新事件列表
      add(LoadCalendarEvents());
    } catch (e) {
      emit(CalendarOperationFailed('創建事件失敗', e));
    }
  }

  /// 處理更新事件的事件
  Future<void> _onUpdateCalendarEvent(
    UpdateCalendarEvent event,
    Emitter<CalendarState> emit,
  ) async {
    try {
      emit(CalendarEventsLoading());
      final updatedEvent = await _repository.updateEvent(event.event);
      emit(CalendarEventUpdated(updatedEvent));

      // 刷新事件列表
      add(LoadCalendarEvents());
    } catch (e) {
      emit(CalendarOperationFailed('更新事件失敗', e));
    }
  }

  /// 處理移動事件的事件
  Future<void> _onMoveCalendarEvent(
    MoveCalendarEvent event,
    Emitter<CalendarState> emit,
  ) async {
    try {
      emit(CalendarEventsLoading());
      final movedEvent = await _repository.moveEvent(
        eventId: event.eventId,
        baseId: event.baseId,
        boardId: event.boardId,
        tableId: event.tableId,
        rowId: event.rowId,
        columnId: event.columnId,
      );
      emit(CalendarEventUpdated(movedEvent));

      // 刷新事件列表
      add(LoadCalendarEvents());
    } catch (e) {
      emit(CalendarOperationFailed('移動事件失敗', e));
    }
  }

  /// 處理變更事件時間的事件
  Future<void> _onChangeCalendarEventTime(
    ChangeCalendarEventTime event,
    Emitter<CalendarState> emit,
  ) async {
    try {
      emit(CalendarEventsLoading());
      final updatedEvent = await _repository.changeEventTime(
        eventId: event.eventId,
        startTime: event.startTime,
        endTime: event.endTime,
        isAllDay: event.isAllDay,
      );
      emit(CalendarEventUpdated(updatedEvent));

      // 刷新事件列表
      add(LoadCalendarEvents());
    } catch (e) {
      emit(CalendarOperationFailed('變更事件時間失敗', e));
    }
  }

  /// 處理刪除事件的事件
  Future<void> _onDeleteCalendarEvent(
    DeleteCalendarEvent event,
    Emitter<CalendarState> emit,
  ) async {
    try {
      emit(CalendarEventsLoading());
      final success = await _repository.deleteEvent(event.eventId);
      if (success) {
        emit(CalendarEventDeleted(event.eventId));

        // 刷新事件列表
        add(LoadCalendarEvents());
      } else {
        emit(const CalendarOperationFailed('刪除事件失敗'));
      }
    } catch (e) {
      emit(CalendarOperationFailed('刪除事件失敗', e));
    }
  }

  /// 處理批量刪除事件的事件
  Future<void> _onDeleteCalendarEvents(
    DeleteCalendarEvents event,
    Emitter<CalendarState> emit,
  ) async {
    try {
      emit(CalendarEventsLoading());
      final success = await _repository.deleteEvents(event.eventIds);
      if (success) {
        emit(CalendarEventsDeleted(event.eventIds));

        // 刷新事件列表
        add(LoadCalendarEvents());
      } else {
        emit(const CalendarOperationFailed('批量刪除事件失敗'));
      }
    } catch (e) {
      emit(CalendarOperationFailed('批量刪除事件失敗', e));
    }
  }
}
