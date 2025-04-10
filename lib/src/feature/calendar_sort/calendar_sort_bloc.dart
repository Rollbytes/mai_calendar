import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mai_calendar/src/models/calendar_models.dart';

import 'calendar_sort_event.dart';
import 'calendar_sort_state.dart';

class CalendarSortBloc extends Bloc<CalendarSortEvent, CalendarSortState> {
  StreamSubscription<List<CalendarEvent>>? _itemsSubscription;
  DateTime? _selectedDate;

  CalendarSortBloc({
    DateTime? selectedDate,
  })  : _selectedDate = selectedDate,
        super(CalendarSortState.init()) {
    on<SortTypeChanged>(_onSortTypeChanged);
    on<GroupExpanded>(_onGroupExpanded);
    on<GroupCollapsed>(_onGroupCollapsed);
    on<ItemsUpdated>(_onItemsUpdated);
    on<UpdateGroupedItems>(_onUpdateGroupedItems);
    on<FetchBoardInfo>(_onFetchBoardInfo);
    on<FetchSourceInfo>(_onFetchSourceInfo);
    on<ClearSorting>(_onClearSorting);
  }

  List<CalendarEvent> _getFilteredItemsByDate(List<CalendarEvent> items) {
    if (_selectedDate == null) return items;

    return items.where((item) {
      final itemDate = item.startTime;
      return itemDate.year == _selectedDate!.year && itemDate.month == _selectedDate!.month && itemDate.day == _selectedDate!.day;
    }).toList();
  }

  void _onSortTypeChanged(SortTypeChanged event, Emitter<CalendarSortState> emit) {
    emit(state.copyWith(
      sortType: event.sortType,
      status: CalendarSortStatus.loading,
    ));
    add(UpdateGroupedItems(sortType: event.sortType));
  }

  void _onGroupExpanded(GroupExpanded event, Emitter<CalendarSortState> emit) {
    final updated = Set<String>.from(state.expandedGroups)..add(event.groupKey);
    emit(state.copyWith(expandedGroups: updated));
  }

  void _onGroupCollapsed(GroupCollapsed event, Emitter<CalendarSortState> emit) {
    final updated = Set<String>.from(state.expandedGroups)..remove(event.groupKey);
    emit(state.copyWith(expandedGroups: updated));
  }

  void _onItemsUpdated(ItemsUpdated event, Emitter<CalendarSortState> emit) {
    emit(state.copyWith(
      items: event.items,
      status: CalendarSortStatus.loaded,
    ));
    add(UpdateGroupedItems(sortType: state.sortType));
  }

  void _onUpdateGroupedItems(UpdateGroupedItems event, Emitter<CalendarSortState> emit) {
    final grouped = <String, List<CalendarEvent>>{};

    switch (event.sortType) {
      case CalendarSortType.none:
        // 不排序，保持空的groupedItems
        break;

      case CalendarSortType.time:
        final formatter = DateFormat('HH:mm');
        for (final item in state.items) {
          final startTime = item.startTime;
          final groupKey = formatter.format(startTime);
          grouped.putIfAbsent(groupKey, () => []).add(item);
        }
        break;

      case CalendarSortType.color:
        for (final item in state.items) {
          final color = item.color;
          grouped.putIfAbsent(color, () => []).add(item);
        }
        break;

      case CalendarSortType.board:
        for (final item in state.items) {
          final source = item.boardName ?? '未知';
          grouped.putIfAbsent(source, () => []).add(item);
        }
        break;
    }

    emit(state.copyWith(
      groupedItems: grouped,
      status: CalendarSortStatus.loaded,
    ));
  }

  void _onFetchSourceInfo(FetchSourceInfo event, Emitter<CalendarSortState> emit) {
    add(ItemsUpdated(event.items));
  }

  void _onFetchBoardInfo(FetchBoardInfo event, Emitter<CalendarSortState> emit) {
    add(ItemsUpdated(event.items));
  }

  void _onClearSorting(ClearSorting event, Emitter<CalendarSortState> emit) {
    emit(state.copyWith(
      groupedItems: {},
      sortType: CalendarSortType.none,
      status: CalendarSortStatus.loaded,
    ));
  }

  @override
  Future<void> close() {
    _itemsSubscription?.cancel();
    return super.close();
  }
}
