import 'package:equatable/equatable.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../models/index.dart';

/// 日曆狀態的可能狀態
enum CalendarStatus {
  initial, // 初始狀態
  loading, // 加載中
  loaded, // 加載完成
  error, // 發生錯誤
  creating, // 創建中
  updating, // 更新中
  deleting, // 刪除中
}

/// 統一的日曆狀態類
class CalendarState extends Equatable {
  // 基本狀態
  final CalendarStatus status;
  final String? errorMessage;
  final Object? error;

  // 視圖和數據
  final CalendarView currentView;
  final List<CalendarEvent> events;
  final CalendarEvent? selectedEvent;

  // 數據請求範圍
  final DateTime? startDate;
  final DateTime? endDate;
  final String? source;

  // 操作結果
  final String? lastCreatedEventId;
  final String? lastUpdatedEventId;
  final String? lastDeletedEventId;
  final List<String>? lastDeletedEventIds;

  // 視圖設置
  final bool showLunarDate;
  final int appointmentDisplayCount;

  /// 創建日曆狀態
  const CalendarState({
    this.status = CalendarStatus.initial,
    this.errorMessage,
    this.error,
    this.currentView = CalendarView.month,
    this.events = const [],
    this.selectedEvent,
    this.startDate,
    this.endDate,
    this.source,
    this.lastCreatedEventId,
    this.lastUpdatedEventId,
    this.lastDeletedEventId,
    this.lastDeletedEventIds,
    this.showLunarDate = false,
    this.appointmentDisplayCount = 3,
  });

  /// 初始狀態
  factory CalendarState.initial() => const CalendarState(
        status: CalendarStatus.initial,
        currentView: CalendarView.month,
        events: [],
        showLunarDate: false,
        appointmentDisplayCount: 3,
      );

  /// 加載中
  CalendarState loading() => copyWith(
        status: CalendarStatus.loading,
      );

  /// 發生錯誤
  CalendarState withError(String message, [Object? errorObject]) => copyWith(
        status: CalendarStatus.error,
        errorMessage: message,
        error: errorObject,
      );

  /// 事件加載成功
  CalendarState eventsLoaded(
    List<CalendarEvent> events, {
    DateTime? startDate,
    DateTime? endDate,
    String? source,
  }) =>
      copyWith(
        status: CalendarStatus.loaded,
        events: events,
        startDate: startDate,
        endDate: endDate,
        source: source,
        errorMessage: null,
        error: null,
      );

  /// 事件創建成功
  CalendarState eventCreated(CalendarEvent event) => copyWith(
        status: CalendarStatus.loaded,
        lastCreatedEventId: event.id,
        selectedEvent: event,
        // 保留現有事件列表，不會清空
      );

  /// 事件更新成功
  CalendarState eventUpdated(CalendarEvent event) => copyWith(
        status: CalendarStatus.loaded,
        lastUpdatedEventId: event.id,
        selectedEvent: event,
        // 保留現有事件列表，不會清空
      );

  /// 事件刪除成功
  CalendarState eventDeleted(String eventId) => copyWith(
        status: CalendarStatus.loaded,
        lastDeletedEventId: eventId,
        // 保留現有事件列表，不會清空
      );

  /// 多個事件刪除成功
  CalendarState eventsDeleted(List<String> eventIds) => copyWith(
        status: CalendarStatus.loaded,
        lastDeletedEventIds: eventIds,
        // 保留現有事件列表，不會清空
      );

  /// 視圖已變更
  CalendarState viewChanged(CalendarView view) => copyWith(
        currentView: view,
        // 保留所有其他數據，包括事件列表
      );

  /// 獲取當前選中事件
  CalendarEvent? get currentEvent => selectedEvent;

  /// 是否處於加載狀態
  bool get isLoading => status == CalendarStatus.loading;

  /// 是否處於錯誤狀態
  bool get isError => status == CalendarStatus.error;

  /// 複製狀態
  CalendarState copyWith({
    CalendarStatus? status,
    String? errorMessage,
    Object? error,
    CalendarView? currentView,
    List<CalendarEvent>? events,
    CalendarEvent? selectedEvent,
    DateTime? startDate,
    DateTime? endDate,
    String? source,
    String? lastCreatedEventId,
    String? lastUpdatedEventId,
    String? lastDeletedEventId,
    List<String>? lastDeletedEventIds,
    bool? showLunarDate,
    int? appointmentDisplayCount,
  }) {
    return CalendarState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      error: error ?? this.error,
      currentView: currentView ?? this.currentView,
      events: events ?? this.events,
      selectedEvent: selectedEvent ?? this.selectedEvent,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      source: source ?? this.source,
      lastCreatedEventId: lastCreatedEventId ?? this.lastCreatedEventId,
      lastUpdatedEventId: lastUpdatedEventId ?? this.lastUpdatedEventId,
      lastDeletedEventId: lastDeletedEventId ?? this.lastDeletedEventId,
      lastDeletedEventIds: lastDeletedEventIds ?? this.lastDeletedEventIds,
      showLunarDate: showLunarDate ?? this.showLunarDate,
      appointmentDisplayCount: appointmentDisplayCount ?? this.appointmentDisplayCount,
    );
  }

  @override
  List<Object?> get props => [
        status,
        errorMessage,
        error,
        currentView,
        events,
        selectedEvent,
        startDate,
        endDate,
        source,
        lastCreatedEventId,
        lastUpdatedEventId,
        lastDeletedEventId,
        lastDeletedEventIds,
        showLunarDate,
        appointmentDisplayCount,
      ];
}
