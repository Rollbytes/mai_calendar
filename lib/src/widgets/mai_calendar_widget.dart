import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:lunar/calendar/Lunar.dart';
import '../repositories/mai_calendar_data_source.dart';
import '../calendar_bloc/calendar_bloc.dart';
import '../calendar_bloc/calendar_event.dart' as bloc_event;
import '../calendar_bloc/calendar_state.dart';
import 'mai_calendar_editor.dart';
import 'mai_calendar_events_of_day_view.dart';

/// Mai Calendar Widget
/// 一個使用 Syncfusion Calendar 來顯示 Mai.today 行事曆事件的小部件
class MaiCalendarWidget extends StatefulWidget {
  /// 當前視圖類型
  final CalendarView initialView;

  /// 首先可見的日期
  final DateTime? initialDisplayDate;

  /// 是否允許視圖切換
  final bool allowViewNavigation;

  /// 是否顯示農曆
  final bool showLunarDate;

  /// 每個單元格最多顯示的事件數量
  final int appointmentDisplayCount;

  final CalendarBloc calendarBloc;
  const MaiCalendarWidget({
    super.key,
    this.initialView = CalendarView.month,
    this.initialDisplayDate,
    this.allowViewNavigation = false,
    this.showLunarDate = false,
    this.appointmentDisplayCount = 3,
    required this.calendarBloc,
  });

  @override
  State<MaiCalendarWidget> createState() => _MaiCalendarWidgetState();
}

class _MaiCalendarWidgetState extends State<MaiCalendarWidget> {
  late CalendarController _calendarController;
  late CalendarBloc _calendarBloc;
  DateTime _currentViewDate = DateTime.now();
  CalendarView _currentView = CalendarView.month;
  final DateTime _now = DateTime.now();
  bool _showLunarDate = false;
  int _appointmentDisplayCount = 3;

  @override
  void initState() {
    super.initState();
    // 初始化農曆日期顯示
    _showLunarDate = widget.showLunarDate;
    _appointmentDisplayCount = widget.appointmentDisplayCount;

    _calendarBloc = widget.calendarBloc;
    _calendarController = _calendarBloc.calendarController;
    _currentView = widget.initialView;
    _currentViewDate = widget.initialDisplayDate ?? DateTime.now();

    // 初始加載事件
    _loadEventsForCurrentView();
  }

  @override
  void didUpdateWidget(MaiCalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showLunarDate != widget.showLunarDate) {
      setState(() {
        _showLunarDate = widget.showLunarDate;
      });
    }
    if (oldWidget.appointmentDisplayCount != widget.appointmentDisplayCount) {
      setState(() {
        _appointmentDisplayCount = widget.appointmentDisplayCount;
      });
    }
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  /// 加載當前視圖範圍內的事件
  void _loadEventsForCurrentView() {
    final viewStartDate = _getViewStartDate();
    final viewEndDate = _getViewEndDate();

    _calendarBloc.add(
      bloc_event.LoadCalendarEvents(
        start: viewStartDate,
        end: viewEndDate,
      ),
    );
  }

  /// 自定義月曆單元格構建器
  Widget _buildMonthCell(BuildContext context, MonthCellDetails details) {
    final lunarDate = Lunar.fromDate(details.date);
    final lunarDay = lunarDate.getDay();
    final lunarMonth = lunarDate.getMonth();

    final bool isToday = details.date.day == _now.day && details.date.month == _now.month && details.date.year == _now.year;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 0.5, color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              '${details.date.day}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isToday ? Theme.of(context).colorScheme.primary : null,
              ),
            ),
          ),
          if (_showLunarDate)
            Text(
              "$lunarMonth/$lunarDay",
              style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
        ],
      ),
    );
  }

  /// 獲取當前視圖的開始日期
  DateTime _getViewStartDate() {
    switch (_currentView) {
      case CalendarView.day:
        return DateTime(_currentViewDate.year, _currentViewDate.month, _currentViewDate.day);
      case CalendarView.week:
        final weekStart = _currentViewDate.subtract(Duration(days: _currentViewDate.weekday - 1));
        return DateTime(weekStart.year, weekStart.month, weekStart.day);
      case CalendarView.workWeek:
        final weekStart = _currentViewDate.subtract(Duration(days: _currentViewDate.weekday - 1));
        return DateTime(weekStart.year, weekStart.month, weekStart.day);
      case CalendarView.month:
        return DateTime(_currentViewDate.year, _currentViewDate.month, 1);
      case CalendarView.timelineDay:
        return DateTime(_currentViewDate.year, _currentViewDate.month, _currentViewDate.day);
      case CalendarView.timelineWeek:
        final weekStart = _currentViewDate.subtract(Duration(days: _currentViewDate.weekday - 1));
        return DateTime(weekStart.year, weekStart.month, weekStart.day);
      case CalendarView.timelineWorkWeek:
        final weekStart = _currentViewDate.subtract(Duration(days: _currentViewDate.weekday - 1));
        return DateTime(weekStart.year, weekStart.month, weekStart.day);
      case CalendarView.timelineMonth:
        return DateTime(_currentViewDate.year, _currentViewDate.month, 1);
      case CalendarView.schedule:
        return DateTime(_currentViewDate.year, _currentViewDate.month, 1);
    }
  }

  /// 獲取當前視圖的結束日期
  DateTime _getViewEndDate() {
    switch (_currentView) {
      case CalendarView.day:
        return DateTime(_currentViewDate.year, _currentViewDate.month, _currentViewDate.day, 23, 59, 59);
      case CalendarView.week:
        final weekStart = _currentViewDate.subtract(Duration(days: _currentViewDate.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        return DateTime(weekEnd.year, weekEnd.month, weekEnd.day, 23, 59, 59);
      case CalendarView.workWeek:
        final weekStart = _currentViewDate.subtract(Duration(days: _currentViewDate.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 4)); // 工作周是5天
        return DateTime(weekEnd.year, weekEnd.month, weekEnd.day, 23, 59, 59);
      case CalendarView.month:
        final monthEnd = DateTime(_currentViewDate.year, _currentViewDate.month + 1, 0);
        return DateTime(monthEnd.year, monthEnd.month, monthEnd.day, 23, 59, 59);
      case CalendarView.timelineDay:
        return DateTime(_currentViewDate.year, _currentViewDate.month, _currentViewDate.day, 23, 59, 59);
      case CalendarView.timelineWeek:
        final weekStart = _currentViewDate.subtract(Duration(days: _currentViewDate.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        return DateTime(weekEnd.year, weekEnd.month, weekEnd.day, 23, 59, 59);
      case CalendarView.timelineWorkWeek:
        final weekStart = _currentViewDate.subtract(Duration(days: _currentViewDate.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 4)); // 工作周是5天
        return DateTime(weekEnd.year, weekEnd.month, weekEnd.day, 23, 59, 59);
      case CalendarView.timelineMonth:
        final monthEnd = DateTime(_currentViewDate.year, _currentViewDate.month + 1, 0);
        return DateTime(monthEnd.year, monthEnd.month, monthEnd.day, 23, 59, 59);
      case CalendarView.schedule:
        final monthEnd = DateTime(_currentViewDate.year, _currentViewDate.month + 1, 0);
        return DateTime(monthEnd.year, monthEnd.month, monthEnd.day, 23, 59, 59);
    }
  }

  /// 顯示底部表單
  void _showBottomSheet() {
    MaiCalendarEditor.show(
      context: context,
      currentDate: _currentViewDate,
      calendarBloc: _calendarBloc,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CalendarBloc, CalendarState>(
      bloc: _calendarBloc,
      listener: (context, state) {
        // 可以在這裡處理一些通知或彈窗
        if (state.isError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? '操作失敗')),
          );
        }
      },
      builder: (context, state) {
        return Stack(
          children: [
            _buildCalendar(state),
            // 添加浮動按鈕
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton(
                onPressed: _showBottomSheet,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 構建行事曆組件
  Widget _buildCalendar(CalendarState state) {
    if (state.isLoading && state.events.isEmpty) {
      // 只有在沒有加載過事件的情況下顯示加載中
      return const Center(child: CircularProgressIndicator());
    }

    return SfCalendar(
      controller: _calendarController,
      view: _currentView,
      firstDayOfWeek: 1, // 週一作為一週的第一天
      initialDisplayDate: widget.initialDisplayDate ?? DateTime.now(),
      dataSource: MaiCalendarDataSource(state.events),
      allowViewNavigation: widget.allowViewNavigation,
      showNavigationArrow: false,
      showWeekNumber: false,
      headerHeight: 0,
      viewHeaderStyle: const ViewHeaderStyle(
        dayTextStyle: TextStyle(fontWeight: FontWeight.w500),
        dateTextStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
      monthViewSettings: MonthViewSettings(
        appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
        showAgenda: false,
        appointmentDisplayCount: _appointmentDisplayCount,
        agendaStyle: const AgendaStyle(
          backgroundColor: Colors.white,
          appointmentTextStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      timeSlotViewSettings: const TimeSlotViewSettings(
        timeFormat: 'HH:mm',
        timeTextStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      monthCellBuilder: _buildMonthCell,
      onTap: (CalendarTapDetails details) {
        if (details.targetElement == CalendarElement.calendarCell && details.date != null && _calendarBloc.state.currentView == CalendarView.month) {
          // 點擊日曆單元格時，使用 MaiCalendarDayEvents 顯示當天事件
          MaiCalendarEventsOfDayView.show(
            context: context,
            selectedDate: details.date!,
            calendarBloc: _calendarBloc,
            floatingActionButton: FloatingActionButton(
              onPressed: () => MaiCalendarEditor.show(context: context, currentDate: details.date!, calendarBloc: _calendarBloc),
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          );
        }
      },
    );
  }
}
