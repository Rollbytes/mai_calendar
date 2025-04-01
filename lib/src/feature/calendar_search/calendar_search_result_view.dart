import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mai_calendar/src/feature/calendar_sort/calendar_sort_bloc.dart';
import 'package:mai_calendar/src/feature/calendar_sort/calendar_sort_state.dart';
import 'package:mai_calendar/src/feature/color_picker/hex_color_adapter.dart';
import '../../../src/models/index.dart';
import 'calendar_search_bloc.dart';
import 'calendar_search_event.dart';
import 'calendar_search_state.dart';

/// 行事曆搜尋結果頁面
class CalendarSearchResultView extends StatefulWidget {
  const CalendarSearchResultView({super.key, required this.calendarSearchBloc, required this.calendarSortBloc});
  final CalendarSearchBloc calendarSearchBloc;
  final CalendarSortBloc calendarSortBloc;

  @override
  State<CalendarSearchResultView> createState() => _CalendarSearchResultViewState();
}

class _CalendarSearchResultViewState extends State<CalendarSearchResultView> {
  final TextEditingController _searchController = TextEditingController();
  late CalendarSortBloc _calendarSortBloc;
  late CalendarSearchBloc _calendarSearchBloc;

  @override
  void initState() {
    super.initState();
    _calendarSearchBloc = widget.calendarSearchBloc;
    _calendarSortBloc = widget.calendarSortBloc;
    _calendarSearchBloc.add(const LoadAllCalendarEvents());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: const Text('搜尋行事曆'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildSearchField(),
          ),
          Expanded(
            child: _buildSearchResults(),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextFormField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: '搜尋行事曆事件',
          prefixIcon: const Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          suffixIcon: BlocBuilder<CalendarSearchBloc, CalendarSearchState>(
            bloc: _calendarSearchBloc,
            builder: (context, state) {
              return state.searchText.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _calendarSearchBloc.add(ClearSearch());
                      },
                    )
                  : const SizedBox.shrink();
            },
          ),
        ),
        onChanged: (value) {
          _calendarSearchBloc.add(SearchTextChanged(value));
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    return BlocBuilder<CalendarSearchBloc, CalendarSearchState>(
      bloc: _calendarSearchBloc,
      builder: (context, state) {
        if (state.status == CalendarSearchStatus.initial) {
          return const Center(
            child: Text('請輸入搜尋關鍵字'),
          );
        }

        if (state.status == CalendarSearchStatus.loading) {
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        }

        if (state.status == CalendarSearchStatus.error) {
          return Center(
            child: Text(state.errorMessage ?? '搜尋發生錯誤'),
          );
        }

        if (state.searchResults.isEmpty) {
          return const Center(
            child: Text('找不到符合的行事曆事件'),
          );
        }

        return ListView.separated(
          itemCount: state.searchResults.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final event = state.searchResults[index];
            return _buildAppointmentItem(event);
          },
        );
      },
    );
  }

  Widget _buildBottomButton() {
    return BlocBuilder<CalendarSearchBloc, CalendarSearchState>(
      bloc: _calendarSearchBloc,
      builder: (context, state) {
        if (state.status != CalendarSearchStatus.loaded || state.searchResults.isEmpty) {
          return const SizedBox();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: ElevatedButton(
              onPressed: () {
                // 在行事曆中顯示所有搜尋結果
                Navigator.pop(context);
                // TODO: 實現在行事曆中顯示搜尋結果的功能
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('在行事曆中顯示搜尋結果'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppointmentItem(CalendarEvent event) {
    return InkWell(
      onTap: () {},
      child: SizedBox(
        height: 50,
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: [
            const SizedBox(width: 16),
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: HexColor.parse(event.color),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      event.title,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _formatTimeDisplay(event.startTime.toLocal(), event.endTime?.toLocal()),
                      style: const TextStyle(fontSize: 12, color: Colors.grey, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  String _formatTimeDisplay(DateTime startTime, DateTime? endTime) {
    final timeFormat = DateFormat('ah:mm', 'zh_TW');
    final dateTimeFormat = DateFormat('yyyy/M/d ah:mm', 'zh_TW');

    // 檢查是否為時間排序
    final isTimeSort = _calendarSortBloc.state.sortType == CalendarSortType.time;

    if (endTime == null) {
      return isTimeSort ? dateTimeFormat.format(startTime) : timeFormat.format(startTime);
    } else {
      if (isTimeSort) {
        return '${dateTimeFormat.format(startTime)} - ${dateTimeFormat.format(endTime)}';
      } else {
        return '${timeFormat.format(startTime)} - ${timeFormat.format(endTime)}';
      }
    }
  }
}
