import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:lunar/calendar/Lunar.dart';
import '../repositories/mai_calendar_data_source.dart';
import '../calendar_bloc/calendar_bloc.dart';
import '../calendar_bloc/calendar_state.dart';
import 'mai_calendar_editor.dart';
import 'mai_calendar_events_of_day_view.dart';
import 'mai_calendar_appointment_builder.dart';

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

  /// 視圖變化回調
  final Function(ViewChangedDetails)? onViewChanged;

  /// 日曆 Bloc
  final CalendarBloc calendarBloc;

  /// 是否顯示添加按鈕
  final bool showAddButton;

  const MaiCalendarWidget({
    super.key,
    this.initialView = CalendarView.month,
    this.initialDisplayDate,
    this.allowViewNavigation = false,
    this.showLunarDate = false,
    this.appointmentDisplayCount = 3,
    this.onViewChanged,
    required this.calendarBloc,
    this.showAddButton = true,
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
    // 添加對初始視圖變化的檢測
    if (oldWidget.initialView != widget.initialView) {
      setState(() {
        _currentView = widget.initialView;
        _calendarController.view = widget.initialView;
      });
    }
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
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
          // 日期部分
          Container(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              '${details.date.day}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isToday ? Theme.of(context).colorScheme.primary : null,
              ),
            ),
          ),
          // 農曆日期
          if (_showLunarDate)
            Container(
              padding: const EdgeInsets.only(bottom: 2.0),
              child: Text(
                "$lunarMonth/$lunarDay",
                style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          // 為行程事件預留空間
          SizedBox(height: _showLunarDate ? 4.0 : 2.0),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CalendarBloc, CalendarState>(
      bloc: _calendarBloc,
      listener: (context, state) {
        // 處理錯誤通知
        if (state.isError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? '操作失敗')),
          );
        }

        // 處理視圖變化
        if (_currentView != state.currentView) {
          setState(() {
            _currentView = state.currentView;
            // 確保控制器的視圖與狀態保持同步
            if (_calendarController.view != state.currentView) {
              _calendarController.view = state.currentView;
            }
          });
        }
      },
      builder: (context, state) {
        return Stack(
          children: [
            _buildCalendar(state),
            // 添加浮動按鈕
            if (widget.showAddButton)
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton(
                  onPressed: () => MaiCalendarEditor.show(
                    context: context,
                    currentDate: _currentViewDate,
                    calendarBloc: _calendarBloc,
                  ),
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

    // 更新當前視圖以匹配state中的視圖
    if (_currentView != state.currentView) {
      _currentView = state.currentView;
    }

    final dataSource = MaiCalendarDataSource(state.events);

    return SfCalendar(
      controller: _calendarController,
      view: _currentView,
      firstDayOfWeek: 1, // 週一作為一週的第一天
      initialDisplayDate: widget.initialDisplayDate ?? DateTime.now(),
      dataSource: dataSource,
      allowViewNavigation: widget.allowViewNavigation,
      showNavigationArrow: false,
      showWeekNumber: false,
      onViewChanged: (ViewChangedDetails details) {
        if (widget.onViewChanged != null) {
          widget.onViewChanged!(details);
        }
      },
      scheduleViewSettings: ScheduleViewSettings(
          hideEmptyScheduleWeek: false,
          appointmentItemHeight: 50.0,
          monthHeaderSettings: MonthHeaderSettings(
            backgroundColor: Colors.transparent,
            monthTextStyle: TextStyle(fontSize: 16),
            textAlign: TextAlign.start,
            height: 24,
          ),
          weekHeaderSettings: WeekHeaderSettings(),
          dayHeaderSettings: DayHeaderSettings(width: 50, dayFormat: 'EEEE'),
          appointmentTextStyle: TextStyle(fontSize: 14)),
      appointmentBuilder: (context, details) => MaiCalendarAppointmentBuilder(
        viewType: _calendarController.view,
        details: details,
        calendarBloc: _calendarBloc,
      ),
      headerHeight: 0,
      viewHeaderStyle: const ViewHeaderStyle(
        dayTextStyle: TextStyle(fontWeight: FontWeight.w500),
        dateTextStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
      cellEndPadding: 8, // 減小下方填充，留更多空間給行程標題
      monthViewSettings: MonthViewSettings(
        appointmentDisplayMode: MonthAppointmentDisplayMode.appointment, // 維持原有的行程顯示模式
        showAgenda: false,
        appointmentDisplayCount: _appointmentDisplayCount,
        agendaStyle: const AgendaStyle(
          backgroundColor: Colors.white,
          appointmentTextStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        // 調整月視圖的設置
        navigationDirection: MonthNavigationDirection.horizontal,
        monthCellStyle: MonthCellStyle(
          leadingDatesBackgroundColor: Colors.grey[100],
          trailingDatesBackgroundColor: Colors.grey[100],
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
            floatingActionButton: widget.showAddButton
                ? FloatingActionButton(
                    onPressed: () => MaiCalendarEditor.show(context: context, currentDate: details.date!, calendarBloc: _calendarBloc),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: const Icon(Icons.add, color: Colors.white),
                  )
                : null,
          );
        }
      },
    );
  }
}
