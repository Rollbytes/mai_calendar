import 'package:equatable/equatable.dart';
import 'package:mai_calendar/src/models/calendar_models.dart';

enum CalendarSortStatus { initial, loading, loaded, error }

enum CalendarSortType {
  none, // 無排序
  time, // 按時間排序
  color, // 按顏色排序
  board, // 按來源排序
}

class CalendarSortState extends Equatable {
  final CalendarSortType sortType;
  final Map<String, List<CalendarEvent>> groupedItems;
  final Set<String> expandedGroups;
  final Map<String, String> columnToBoardMap;
  final CalendarSortStatus status;
  final List<CalendarEvent> items;

  const CalendarSortState({
    this.sortType = CalendarSortType.none,
    this.groupedItems = const {},
    this.expandedGroups = const {},
    this.columnToBoardMap = const {},
    this.status = CalendarSortStatus.initial,
    this.items = const [],
  });

  @override
  List<Object?> get props => [
        sortType,
        groupedItems,
        expandedGroups,
        columnToBoardMap,
        status,
        items,
      ];

  // 初始化方法
  factory CalendarSortState.init() {
    return CalendarSortState(
      sortType: CalendarSortType.none,
      groupedItems: {},
      expandedGroups: {},
      items: [],
      status: CalendarSortStatus.initial,
    );
  }

  CalendarSortState copyWith({
    CalendarSortType? sortType,
    Map<String, List<CalendarEvent>>? groupedItems,
    Set<String>? expandedGroups,
    Map<String, String>? columnToBoardMap,
    CalendarSortStatus? status,
    List<CalendarEvent>? items,
  }) {
    return CalendarSortState(
      sortType: sortType ?? this.sortType,
      groupedItems: groupedItems ?? this.groupedItems,
      expandedGroups: expandedGroups ?? this.expandedGroups,
      columnToBoardMap: columnToBoardMap ?? this.columnToBoardMap,
      status: status ?? this.status,
      items: items ?? this.items,
    );
  }
}
