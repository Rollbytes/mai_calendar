import '../../../src/models/index.dart';

/// 行事曆搜尋事件基類
abstract class CalendarSearchEvent {
  const CalendarSearchEvent();
}

/// 加載所有行事曆事件
class LoadAllCalendarEvents extends CalendarSearchEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadAllCalendarEvents({this.startDate, this.endDate});
}

/// 搜尋文字變更事件
class SearchTextChanged extends CalendarSearchEvent {
  final String searchText;

  const SearchTextChanged(this.searchText);
}

/// 清除搜尋事件
class ClearSearch extends CalendarSearchEvent {}

/// 開始搜尋事件
class StartSearch extends CalendarSearchEvent {}

/// 搜尋完成事件
class SearchCompleted extends CalendarSearchEvent {
  final List<CalendarEvent> searchResults;

  const SearchCompleted(this.searchResults);
}

/// 搜尋出錯事件
class SearchError extends CalendarSearchEvent {
  final String message;
  final Object? error;

  const SearchError(this.message, [this.error]);
}
