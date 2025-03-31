import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _calendarBloc,
      child: SafeArea(
        child: BlocBuilder<CalendarBloc, CalendarState>(
          builder: (context, state) {
            return Column(
              children: [
                // 頂部操作區域
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '行事曆',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          // 視圖切換按鈕
                          PopupMenuButton<CalendarView>(
                            tooltip: '切換視圖',
                            icon: const Icon(Icons.view_day),
                            onSelected: (CalendarView view) {
                              _calendarBloc.add(ChangeCalendarView(view));
                            },
                            itemBuilder: (BuildContext context) => <PopupMenuEntry<CalendarView>>[
                              const PopupMenuItem<CalendarView>(
                                value: CalendarView.day,
                                child: Text('日視圖'),
                              ),
                              const PopupMenuItem<CalendarView>(
                                value: CalendarView.week,
                                child: Text('週視圖'),
                              ),
                              const PopupMenuItem<CalendarView>(
                                value: CalendarView.month,
                                child: Text('月視圖'),
                              ),
                              const PopupMenuItem<CalendarView>(
                                value: CalendarView.schedule,
                                child: Text('行程視圖'),
                              ),
                            ],
                          ),
                        ],
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
      ),
    );
  }
}
