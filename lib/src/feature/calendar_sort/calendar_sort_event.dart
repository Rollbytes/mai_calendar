import 'package:mai_calendar/src/models/calendar_models.dart';
import 'calendar_sort_state.dart';

abstract class CalendarSortEvent {}

class SortTypeChanged extends CalendarSortEvent {
  final CalendarSortType sortType;
  SortTypeChanged(this.sortType);
}

class GroupExpanded extends CalendarSortEvent {
  final String groupKey;
  GroupExpanded(this.groupKey);
}

class GroupCollapsed extends CalendarSortEvent {
  final String groupKey;
  GroupCollapsed(this.groupKey);
}

class ItemsUpdated extends CalendarSortEvent {
  final List<CalendarEvent> items;
  ItemsUpdated(this.items);
}

class UpdateGroupedItems extends CalendarSortEvent {
  final CalendarSortType sortType;
  UpdateGroupedItems({required this.sortType});
}

// 清除排序事件
class ClearSorting extends CalendarSortEvent {}

// 獲取行程來源資訊
class FetchBoardInfo extends CalendarSortEvent {
  final List<CalendarEvent> items;
  FetchBoardInfo(this.items);
}

// 獲取行程來源資訊
class FetchSourceInfo extends CalendarSortEvent {
  final List<CalendarEvent> items;
  FetchSourceInfo(this.items);
}
