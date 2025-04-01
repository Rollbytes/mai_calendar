import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mai_calendar/src/feature/calendar_sort/calendar_sort_bloc.dart';
import 'package:mai_calendar/src/feature/calendar_sort/calendar_sort_event.dart';
import 'package:mai_calendar/src/feature/calendar_sort/calendar_sort_state.dart';

/// 行事曆排序按鈕
/// 用於顯示和設置行事曆的排序方式
class CalendarSortButton extends StatelessWidget {
  /// 排序 Bloc
  final CalendarSortBloc calendarSortBloc;

  /// 建立行事曆排序按鈕
  const CalendarSortButton({
    super.key,
    required this.calendarSortBloc,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarSortBloc, CalendarSortState>(
      bloc: calendarSortBloc,
      builder: (context, sortState) {
        return PopupMenuButton<CalendarSortType>(
          tooltip: '',
          color: Colors.white,
          offset: const Offset(0, 32),
          constraints: const BoxConstraints(
            minWidth: 80,
            maxWidth: 130,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(
              Icons.swap_vert_outlined,
              color: sortState.sortType == CalendarSortType.none ? Colors.grey : Colors.blue,
              size: 24,
            ),
          ),
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<CalendarSortType>(
              enabled: false,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.swap_vert_outlined, color: Colors.black, size: 18),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '排序方式',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            PopupMenuItem<CalendarSortType>(
              value: CalendarSortType.time,
              child: Container(
                decoration: BoxDecoration(
                  color: sortState.sortType == CalendarSortType.time && sortState.groupedItems.isNotEmpty ? Colors.blue.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Text(
                  '時間',
                  style: TextStyle(
                    color: sortState.sortType == CalendarSortType.time && sortState.groupedItems.isNotEmpty ? Colors.blue[800] : Colors.black,
                    fontWeight: sortState.sortType == CalendarSortType.time && sortState.groupedItems.isNotEmpty ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
            PopupMenuItem<CalendarSortType>(
              value: CalendarSortType.color,
              child: Container(
                decoration: BoxDecoration(
                  color: sortState.sortType == CalendarSortType.color ? Colors.blue.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Text(
                  '顏色',
                  style: TextStyle(
                    color: sortState.sortType == CalendarSortType.color ? Colors.blue[800] : Colors.black,
                    fontWeight: sortState.sortType == CalendarSortType.color ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
            PopupMenuItem<CalendarSortType>(
              value: CalendarSortType.board,
              child: Container(
                decoration: BoxDecoration(
                  color: sortState.sortType == CalendarSortType.board ? Colors.blue.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Text(
                  '來源',
                  style: TextStyle(
                    color: sortState.sortType == CalendarSortType.board ? Colors.blue[800] : Colors.black,
                    fontWeight: sortState.sortType == CalendarSortType.board ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
            if (sortState.groupedItems.isNotEmpty)
              PopupMenuItem<CalendarSortType>(
                value: CalendarSortType.none,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: const Text(
                    '取消排序',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
          ],
          onSelected: (CalendarSortType value) {
            if (value == CalendarSortType.none) {
              calendarSortBloc.add(ClearSorting());
            } else {
              calendarSortBloc.add(SortTypeChanged(value));
            }
          },
        );
      },
    );
  }
}
