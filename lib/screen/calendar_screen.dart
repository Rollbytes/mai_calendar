import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../src/calendar_bloc/calendar_bloc.dart';
import '../src/calendar_bloc/calendar_event.dart';
import '../src/calendar_bloc/calendar_state.dart';
import '../src/repositories/calendar_repository.dart';
import '../src/widgets/mai_calendar_widget.dart';

/// 行事曆示例頁面
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late CalendarRepository _repository;
  late CalendarBloc _calendarBloc;

  @override
  void initState() {
    super.initState();
    // 初始化語言區域設定
    initializeDateFormatting('zh_TW', null);

    // 初始化依賴
    _repository = CalendarRepository();
    _calendarBloc = CalendarBloc(repository: _repository);

    // 載入初始事件
    _calendarBloc.add(const LoadCalendarEvents());
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
                      _calendarBloc.add(ChangeCalendarView(_calendarBloc.allowedViews[value]));
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
                  child: Text(
                    ' 月視角設定 ',
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
                        _calendarBloc.add(ToggleLunarDate(value));
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
                      _calendarBloc.add(UpdateAppointmentDisplayCount(value));
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
                          Text('${state.appointmentDisplayCount}', style: const TextStyle(color: Colors.black)),
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
    return SafeArea(
      child: BlocBuilder<CalendarBloc, CalendarState>(
        bloc: _calendarBloc,
        builder: (context, state) {
          return Column(
            children: [
              // 頂部操作區域
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () {
                            // 顯示側邊欄或其他操作
                          },
                        ),
                        TextButton(
                          onPressed: () {
                            // 顯示日期選擇器
                          },
                          child: Text(
                            DateFormat('yyyy年MM月', 'zh_TW').format(DateTime.now()),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () => _showOptionsMenu(context),
                    ),
                  ],
                ),
              ),
              // 日曆部分
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
                      ),
                      // 加載指示器
                      if (state.isLoading && state.events.isEmpty)
                        const Center(
                          child: CircularProgressIndicator(),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
