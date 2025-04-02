import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mai_calendar/src/calendar_bloc/calendar_bloc.dart';
import 'package:mai_calendar/src/calendar_bloc/calendar_event.dart' as bloc_event;
import 'package:mai_calendar/src/calendar_bloc/calendar_state.dart';
import 'package:mai_calendar/src/feature/calendar_search/calendar_search_bloc.dart';
import 'package:mai_calendar/src/feature/calendar_search/calendar_search_state.dart';
import 'package:mai_calendar/src/models/index.dart';
import 'package:mai_calendar/src/repositories/calendar_repository.dart';
import 'package:mai_calendar/src/widgets/mai_calendar_widget.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

/// 搜尋結果行事曆視圖
///
/// 顯示搜尋結果在行事曆上
class SearchCalendarView extends StatefulWidget {
  final CalendarSearchBloc calendarSearchBloc;
  final List<CalendarEvent>? searchResults;
  final String? searchTitle;

  const SearchCalendarView({
    super.key,
    required this.calendarSearchBloc,
    this.searchResults,
    this.searchTitle,
  });

  @override
  State<SearchCalendarView> createState() => _SearchCalendarViewState();
}

class _SearchCalendarViewState extends State<SearchCalendarView> {
  late CalendarBloc _calendarBloc;
  CalendarView _currentView = CalendarView.month;
  final GlobalKey _appBarKey = GlobalKey();
  List<CalendarEvent> _currentResults = [];
  late CalendarSearchBloc _calendarSearchBloc;

  @override
  void initState() {
    super.initState();
    _calendarSearchBloc = widget.calendarSearchBloc;

    // 初始化搜尋結果專用的 CalendarBloc
    _calendarBloc = CalendarBloc(repository: CalendarRepository());

    // 如果已經有搜尋結果，初始化當前結果並加載到日曆
    if (widget.searchResults != null && widget.searchResults!.isNotEmpty) {
      _currentResults = widget.searchResults!;
      _loadSearchResultsToCalendar(_currentResults);
    }
  }

  /// 加載搜尋結果到日曆
  void _loadSearchResultsToCalendar(List<CalendarEvent> results) {
    // 使用新的 LoadSearchResults 事件加載搜尋結果
    _calendarBloc.add(bloc_event.LoadSearchResults(
      searchResults: results,
      keepOriginalEvents: false,
      source: 'search',
    ));
  }

  @override
  void dispose() {
    _calendarBloc.close();
    super.dispose();
  }

  /// 顯示選項菜單
  void _showOptionsMenu(BuildContext context) {
    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(100, 110, 0, 0),
      items: [
        // 行事曆視角選擇
        PopupMenuItem<String>(
          enabled: false,
          child: BlocBuilder<CalendarBloc, CalendarState>(
            bloc: _calendarBloc,
            builder: (context, state) {
              return Row(
                children: [
                  const Text('行事曆視角', style: TextStyle(color: Colors.black)),
                  const Spacer(),
                  PopupMenuButton<int>(
                    initialValue: _calendarBloc.allowedViews.indexOf(state.currentView),
                    onSelected: (int value) {
                      _calendarBloc.add(bloc_event.ChangeCalendarView(_calendarBloc.allowedViews[value]));
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                      for (int i = 0; i < _calendarBloc.allowedViews.length; i++)
                        PopupMenuItem<int>(
                          value: i,
                          child: Text(
                            _calendarBloc.getViewNameZhTW(_calendarBloc.allowedViews[i]),
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                    ],
                    constraints: const BoxConstraints(
                      minWidth: 50,
                      maxWidth: 100,
                    ),
                    offset: const Offset(4, 40),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _calendarBloc.getViewNameZhTW(state.currentView),
                            style: const TextStyle(color: Colors.black),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.black),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const PopupMenuItem<String>(enabled: false, height: 8, child: SizedBox()),
        PopupMenuItem<String>(
          enabled: false,
          height: 24,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(bottom: 2.0),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
                    ),
                  ),
                  child: const Text(
                    '月視角設定',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // 農曆日期顯示開關
        PopupMenuItem<String>(
          enabled: false,
          child: BlocBuilder<CalendarBloc, CalendarState>(
            bloc: _calendarBloc,
            builder: (context, state) {
              return Row(
                children: [
                  const Text('農曆日期', style: TextStyle(color: Colors.black)),
                  const Spacer(),
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: state.showLunarDate,
                      activeTrackColor: Theme.of(context).colorScheme.primary,
                      onChanged: (value) {
                        _calendarBloc.add(bloc_event.ToggleLunarDate(value));
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        // 行程顯示數量設定
        PopupMenuItem<String>(
          enabled: false,
          child: BlocBuilder<CalendarBloc, CalendarState>(
            bloc: _calendarBloc,
            builder: (context, state) {
              return Row(
                children: [
                  const Text('行程顯示數量', style: TextStyle(color: Colors.black)),
                  const Spacer(),
                  PopupMenuButton<int>(
                    initialValue: state.appointmentDisplayCount,
                    onSelected: (int value) {
                      _calendarBloc.add(bloc_event.UpdateAppointmentDisplayCount(value));
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                      for (int i = 1; i <= 5; i++)
                        PopupMenuItem<int>(
                          value: i,
                          child: Text('$i', style: const TextStyle(color: Colors.black)),
                        ),
                    ],
                    constraints: const BoxConstraints(
                      minWidth: 50,
                      maxWidth: 100,
                    ),
                    offset: const Offset(4, 40),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(state.appointmentDisplayCount.toString(), style: const TextStyle(color: Colors.black)),
                          const Icon(Icons.arrow_drop_down, color: Colors.black),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final String displayTitle = widget.searchTitle ?? '搜尋結果';
    final String resultCountText = _currentResults.isNotEmpty ? '(${_currentResults.length}筆)' : '';

    return BlocListener<CalendarSearchBloc, CalendarSearchState>(
      bloc: _calendarSearchBloc,
      listener: (context, state) {
        if (state.status == CalendarSearchStatus.loaded && state.searchResults.isNotEmpty) {
          setState(() {
            _currentResults = state.searchResults;
          });
          // 使用新的搜尋結果更新日曆
          _loadSearchResultsToCalendar(_currentResults);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('$displayTitle $resultCountText'),
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
          actions: [
            IconButton(icon: const Icon(Icons.more_vert), onPressed: () => _showOptionsMenu(context)),
          ],
        ),
        body: BlocBuilder<CalendarBloc, CalendarState>(
          bloc: _calendarBloc,
          builder: (context, state) {
            return Column(
              children: [
                // 日期顯示
                _buildDateHeader(context, state),
                // 行事曆部分
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      children: [
                        MaiCalendarWidget(
                          calendarBloc: _calendarBloc,
                          initialView: state.currentView,
                          allowViewNavigation: false,
                          showLunarDate: state.showLunarDate,
                          appointmentDisplayCount: state.appointmentDisplayCount,
                          showAddButton: false,
                        ),
                        // 無搜尋結果提示
                        if (_currentResults.isEmpty)
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                const Text('沒有找到符合的行事曆事件', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDateHeader(BuildContext context, CalendarState state) {
    final DateFormat formatter = DateFormat('yyyy年MM月', 'zh_TW');
    final String dateTitle = formatter.format(DateTime.now());

    return Container(
      key: _appBarKey,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  dateTitle,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                if (_currentResults.isNotEmpty)
                  Chip(
                    label: Text(
                      '${_currentResults.length}筆結果',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () {
              final now = DateTime.now();
              _calendarBloc.calendarController.displayDate = now;
            },
            icon: const Icon(Icons.today, size: 18),
            label: const Text('今天'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
