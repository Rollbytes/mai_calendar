import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../repositories/mai_calendar_data_source.dart';
import '../calendar_bloc/calendar_bloc.dart';
import '../calendar_bloc/calendar_event.dart';
import '../calendar_bloc/calendar_state.dart';
import '../models/index.dart';
import 'mai_calendar_editor.dart';

/// Mai Calendar Widget
/// 一個使用 Syncfusion Calendar 來顯示 Mai.today 行事曆事件的小部件
class MaiCalendarWidget extends StatefulWidget {
  /// 當前視圖類型
  final CalendarView initialView;

  /// 首先可見的日期
  final DateTime? initialDisplayDate;

  /// 是否允許視圖切換
  final bool allowViewNavigation;

  /// 事件點擊回調
  final Function(CalendarEvent)? onEventTap;
  final CalendarBloc calendarBloc;
  const MaiCalendarWidget({
    super.key,
    this.initialView = CalendarView.month,
    this.initialDisplayDate,
    this.allowViewNavigation = false,
    this.onEventTap,
    required this.calendarBloc,
  });

  @override
  State<MaiCalendarWidget> createState() => _MaiCalendarWidgetState();
}

class _MaiCalendarWidgetState extends State<MaiCalendarWidget> {
  late CalendarController _calendarController;
  DateTime _currentViewDate = DateTime.now();
  CalendarView _currentView = CalendarView.month;

  @override
  void initState() {
    super.initState();
    _calendarController = widget.calendarBloc.calendarController;
    _currentView = widget.initialView;
    _currentViewDate = widget.initialDisplayDate ?? DateTime.now();

    // 初始加載事件
    _loadEventsForCurrentView();
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

    context.read<CalendarBloc>().add(
          LoadCalendarEvents(
            start: viewStartDate,
            end: viewEndDate,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CalendarBloc, CalendarState>(
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
      headerStyle: const CalendarHeaderStyle(
        textAlign: TextAlign.center,
        textStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      viewHeaderStyle: const ViewHeaderStyle(
        dayTextStyle: TextStyle(fontWeight: FontWeight.w500),
        dateTextStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
      monthViewSettings: const MonthViewSettings(
        appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
        showAgenda: false,
        agendaStyle: AgendaStyle(
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
      onTap: (CalendarTapDetails details) {
        if (details.targetElement == CalendarElement.calendarCell && details.date != null) {
          // 點擊日曆單元格時，使用創建模式打開底部表單
          MaiCalendarEditor.show(
            context: context,
            currentDate: details.date!,
            mode: MaiCalendarBottomSheetMode.edit,
          );
        }
      },
    );
  }
}
