import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../models/index.dart';
import '../repositories/calendar_repository.dart';
import 'calendar_event.dart';
import 'calendar_state.dart';

/// 行事曆Bloc
class CalendarBloc extends Bloc<CalendarBlocEvent, CalendarState> {
  final CalendarRepository _repository;

  final CalendarController calendarController = CalendarController();

  final List<CalendarView> allowedViews = [
    CalendarView.schedule,
    CalendarView.day,
    CalendarView.week,
    CalendarView.month,
  ];

  CalendarBloc({required CalendarRepository repository})
      : _repository = repository,
        super(CalendarState.initial()) {
    // 註冊事件處理
    on<LoadCalendarEvents>(_onLoadCalendarEvents);
    on<LoadCalendarEvent>(_onLoadCalendarEvent);
    on<CreateCalendarEvent>(_onCreateCalendarEvent);
    on<UpdateCalendarEvent>(_onUpdateCalendarEvent);
    on<DeleteCalendarEvent>(_onDeleteCalendarEvent);
    on<ChangeCalendarView>(_onChangeCalendarView);
    on<CreateSimpleCalendarEvent>(_onCreateSimpleCalendarEvent);
    on<ToggleLunarDate>(_onToggleLunarDate);
    on<UpdateAppointmentDisplayCount>(_onUpdateAppointmentDisplayCount);
  }

  /// 處理加載多個事件的事件
  Future<void> _onLoadCalendarEvents(LoadCalendarEvents event, Emitter<CalendarState> emit) async {
    try {
      emit(state.loading());
      final events = await _repository.getEvents(
        start: event.start,
        end: event.end,
        source: event.source,
      );
      emit(state.eventsLoaded(
        events,
        startDate: event.start,
        endDate: event.end,
        source: event.source,
      ));
    } catch (e) {
      emit(state.withError('加載事件失敗', e));
    }
  }

  /// 處理加載單個事件的事件
  Future<void> _onLoadCalendarEvent(
    LoadCalendarEvent event,
    Emitter<CalendarState> emit,
  ) async {
    try {
      emit(state.loading());
      final calendarEvent = await _repository.getEvent(event.eventId);
      if (calendarEvent != null) {
        // 使用現有事件列表，更新selectedEvent
        emit(state.copyWith(
          status: CalendarStatus.loaded,
          selectedEvent: calendarEvent,
        ));
      } else {
        emit(state.withError('事件不存在'));
      }
    } catch (e) {
      emit(state.withError('加載事件失敗', e));
    }
  }

  /// 處理創建事件的事件
  Future<void> _onCreateCalendarEvent(CreateCalendarEvent event, Emitter<CalendarState> emit) async {
    try {
      emit(state.copyWith(status: CalendarStatus.creating));
      final createdEvent = await _repository.createCalendarEvent(
        title: event.calendarEvent.title,
        startTime: event.calendarEvent.startTime,
        endTime: event.calendarEvent.endTime,
        isAllDay: event.calendarEvent.isAllDay,
        color: event.calendarEvent.color,
      );

      // 將新創建的事件添加到現有事件列表中
      final updatedEvents = List<CalendarEvent>.from(state.events)..add(createdEvent);

      emit(state.copyWith(
        status: CalendarStatus.loaded,
        events: updatedEvents,
        selectedEvent: createdEvent,
        lastCreatedEventId: createdEvent.id,
      ));
    } catch (e) {
      emit(state.withError('創建事件失敗', e));
    }
  }

  /// 處理更新事件的事件
  Future<void> _onUpdateCalendarEvent(
    UpdateCalendarEvent event,
    Emitter<CalendarState> emit,
  ) async {
    try {
      emit(state.copyWith(status: CalendarStatus.updating));
      final updatedEvent = await _repository.updateEvent(event.event);

      // 更新事件列表中的對應事件
      final eventIndex = state.events.indexWhere((e) => e.id == updatedEvent.id);
      final updatedEvents = List<CalendarEvent>.from(state.events);

      if (eventIndex >= 0) {
        updatedEvents[eventIndex] = updatedEvent;
      }

      emit(state.copyWith(
        status: CalendarStatus.loaded,
        events: updatedEvents,
        selectedEvent: updatedEvent,
        lastUpdatedEventId: updatedEvent.id,
      ));
    } catch (e) {
      emit(state.withError('更新事件失敗', e));
    }
  }

  /// 處理刪除事件的事件
  Future<void> _onDeleteCalendarEvent(
    DeleteCalendarEvent event,
    Emitter<CalendarState> emit,
  ) async {
    try {
      emit(state.copyWith(status: CalendarStatus.deleting));
      final success = await _repository.deleteEvent(event.eventId);

      if (success) {
        // 從事件列表中移除已刪除的事件
        final updatedEvents = state.events.where((e) => e.id != event.eventId).toList();

        emit(state.copyWith(
          status: CalendarStatus.loaded,
          events: updatedEvents,
          lastDeletedEventId: event.eventId,
          // 如果當前選中的事件是被刪除的事件，清空選中事件
          selectedEvent: state.selectedEvent?.id == event.eventId ? null : state.selectedEvent,
        ));
      } else {
        emit(state.withError('刪除事件失敗'));
      }
    } catch (e) {
      emit(state.withError('刪除事件失敗', e));
    }
  }

  /// 處理視圖切換
  Future<void> _onChangeCalendarView(ChangeCalendarView event, Emitter<CalendarState> emit) async {
    try {
      calendarController.view = event.view;
      // 強制刷新視圖
      calendarController.displayDate = calendarController.displayDate ?? DateTime.now();
      // 更新視圖類型，保留已加載的事件數據
      emit(state.viewChanged(event.view));
    } catch (e) {
      // 如果設置視圖失敗，記錄錯誤但仍然更新狀態
      emit(state.viewChanged(event.view));
    }
  }

  /// 處理簡單事件創建
  Future<void> _onCreateSimpleCalendarEvent(CreateSimpleCalendarEvent event, Emitter<CalendarState> emit) async {
    try {
      emit(state.copyWith(status: CalendarStatus.creating));

      final calendarEvent = CalendarEvent(
        id: '',
        title: event.title,
        startTime: event.startTime,
        endTime: event.endTime,
        isAllDay: event.isAllDay,
        color: event.color,
      );

      final createdEvent = await _repository.createEvent(calendarEvent);

      // 將新創建的事件添加到現有事件列表中
      final updatedEvents = List<CalendarEvent>.from(state.events)..add(createdEvent);

      emit(state.copyWith(
        status: CalendarStatus.loaded,
        events: updatedEvents,
        selectedEvent: createdEvent,
        lastCreatedEventId: createdEvent.id,
      ));
    } catch (e) {
      emit(state.withError('創建事件失敗', e));
    }
  }

  /// 切換農曆顯示
  Future<void> _onToggleLunarDate(ToggleLunarDate event, Emitter<CalendarState> emit) async {
    emit(state.copyWith(showLunarDate: event.showLunarDate));
  }

  /// 更新行程顯示數量
  Future<void> _onUpdateAppointmentDisplayCount(UpdateAppointmentDisplayCount event, Emitter<CalendarState> emit) async {
    emit(state.copyWith(appointmentDisplayCount: event.count));
  }

  /// 獲取視圖名稱
  String getViewNameZhTW(CalendarView view) {
    switch (view) {
      case CalendarView.day:
        return '日';
      case CalendarView.week:
        return '週';
      case CalendarView.month:
        return '月';
      case CalendarView.schedule:
        return '行程';
      case CalendarView.timelineDay:
        return '時間軸日';
      case CalendarView.timelineWeek:
        return '時間軸週';
      case CalendarView.timelineMonth:
        return '時間軸月';
      default:
        return '';
    }
  }
}
