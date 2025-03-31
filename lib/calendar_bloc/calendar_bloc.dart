import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mai_calendar/models/calendar_models.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../repositories/calendar_repository.dart';
import 'calendar_event.dart';
import 'calendar_state.dart';

/// 行事曆Bloc
class CalendarBloc extends Bloc<CalendarBlocEvent, CalendarState> {
  final CalendarRepository _repository;

  final CalendarController calendarController = CalendarController();

  CalendarBloc({required CalendarRepository repository})
      : _repository = repository,
        super(CalendarInitial()) {
    // 註冊事件處理
    on<LoadCalendarEvents>(_onLoadCalendarEvents);
    on<LoadCalendarEvent>(_onLoadCalendarEvent);
    on<CreateCalendarEvent>(_onCreateCalendarEvent);
    on<UpdateCalendarEvent>(_onUpdateCalendarEvent);
    on<DeleteCalendarEvent>(_onDeleteCalendarEvent);
    on<ChangeCalendarView>(_onChangeCalendarView);
    on<CreateSimpleCalendarEvent>(_onCreateSimpleCalendarEvent);
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

  Future<void> _onChangeCalendarView(ChangeCalendarView event, Emitter<CalendarState> emit) async {
    calendarController.view = event.view;
    emit(CalendarViewChanged(event.view));
  }

  Future<void> _onCreateSimpleCalendarEvent(CreateSimpleCalendarEvent event, Emitter<CalendarState> emit) async {
    final createdEvent = await _repository.createEvent(CalendarEvent(
      title: event.title,
      startTime: event.startTime,
      endTime: event.endTime,
      isAllDay: event.isAllDay,
      color: event.color,
      id: '',
    ));
    emit(CalendarEventCreated(createdEvent));
  }
}
