import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mai_calendar/src/feature/sf_calendar_date_picker/sf_calendar_date_picker.dart';
import 'package:mai_calendar/src/feature/sf_calendar_date_picker/sf_calendar_date_picker_cubit.dart';
import 'package:mai_calendar/src/feature/sf_calendar_date_picker/sf_calendar_date_picker_state.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
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
  late CalendarDatePickerCubit _calendarDatePickerCubit;
  final DateRangePickerController _dateRangePickerController = DateRangePickerController();
  final GlobalKey _appBarKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // 初始化語言區域設定
    initializeDateFormatting('zh_TW', null);

    // 初始化依賴
    _repository = CalendarRepository();
    _calendarBloc = CalendarBloc(repository: _repository);
    _calendarDatePickerCubit = CalendarDatePickerCubit();

    // 載入初始事件
    _calendarBloc.add(const LoadCalendarEvents());
  }

  @override
  void dispose() {
    _calendarBloc.close();
    _dateRangePickerController.dispose();
    super.dispose();
  }

  /// 顯示日期選擇器
  Future<void> showCalendarDatePicker(BuildContext dialogContext, CalendarView currentView) async {
    final RenderBox? renderBox = _appBarKey.currentContext?.findRenderObject() as RenderBox?;
    final appBarSize = renderBox?.size;
    final appBarPosition = renderBox?.localToGlobal(Offset.zero);

    final defaultHeight = MediaQuery.of(dialogContext).size.height * 0.4;
    final defaultWidth = MediaQuery.of(dialogContext).size.width;

    if (appBarSize == null || appBarPosition == null) {
      debugPrint('無法獲取 AppBar 的大小或位置');
      return;
    }

    showDialog(
      context: dialogContext,
      useSafeArea: true,
      barrierColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(top: appBarPosition.dy - 10, left: 8, right: 8),
          child: Dialog(
            alignment: Alignment.topCenter,
            insetPadding: EdgeInsets.zero,
            child: Container(
              height: defaultHeight,
              width: defaultWidth,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SfCalendarDatePicker(
                currentView: currentView,
                displayDate: _calendarDatePickerCubit.state.currentDate,
                dateRangePickerController: _dateRangePickerController,
                onSelectionChanged: (arg) => _onDatePickerSelectionChange(arg, dialogContext, context),
              ),
            ),
          ),
        );
      },
    ).then((_) {
      _calendarDatePickerCubit.toggleDatePickerExpanded(false);
    });
  }

  void _onDatePickerSelectionChange(DateRangePickerSelectionChangedArgs arg, BuildContext dialogContext, BuildContext context) {
    if (arg.value is DateTime) {
      _dateRangePickerController.displayDate = arg.value;
      _calendarBloc.calendarController.displayDate = arg.value;
      _calendarDatePickerCubit.updateDisplayInDatePicker(arg.value);
      Navigator.of(context).pop();
    }
  }

  /// 跳轉到今天
  void _jumpToToday() {
    final now = DateTime.now();
    _calendarBloc.calendarController.displayDate = now;
    _dateRangePickerController.displayDate = now;
    _dateRangePickerController.selectedDate = now;
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
                  child: const Text(
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
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _calendarBloc),
        BlocProvider.value(value: _calendarDatePickerCubit),
      ],
      child: SafeArea(
        child: BlocBuilder<CalendarBloc, CalendarState>(
          bloc: _calendarBloc,
          builder: (context, state) {
            return Column(
              children: [
                // 頂部操作區域
                _buildAppBar(context),
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
                          onViewChanged: (ViewChangedDetails details) => _onViewChanged(details, context),
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

  void _onViewChanged(ViewChangedDetails viewChangedDetails, BuildContext context) {
    if (viewChangedDetails.visibleDates.isNotEmpty) {
      final currentView = _calendarBloc.calendarController.view;
      if (currentView == CalendarView.month) {
        _calendarDatePickerCubit.updateDisplayDateInMonthView(viewChangedDetails.visibleDates);
      } else if (currentView == CalendarView.week) {
        _calendarDatePickerCubit.updateDisplayDateInWeekView(viewChangedDetails.visibleDates);
      } else if (currentView == CalendarView.day) {
        _calendarDatePickerCubit.updateDisplayInDayView(viewChangedDetails.visibleDates);
      } else if (currentView == CalendarView.schedule) {
        // Schedule view needs special handling via calendarController.displayDate
        if (_calendarBloc.calendarController.displayDate != null) {
          _calendarDatePickerCubit.updateDisplayInScheduleView(_calendarBloc.calendarController.displayDate!);
        }
      }
      // 同步 DateRangePicker 的顯示日期
      _dateRangePickerController.displayDate = _calendarBloc.calendarController.displayDate;
    }
  }

  Widget _buildAppBar(BuildContext context) {
    return BlocBuilder<CalendarDatePickerCubit, SfCalendarDatePickerState>(
      builder: (context, dateState) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      key: _appBarKey,
                      child: TextButton(
                        onPressed: () {
                          _calendarDatePickerCubit.toggleDatePickerExpanded(true);
                          showCalendarDatePicker(context, _calendarBloc.calendarController.view ?? CalendarView.month);
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  DateFormat('yyyy年MM月', 'zh_TW').format(dateState.currentDate),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  dateState.isDatePickerExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                                  size: 24,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    onPressed: _jumpToToday,
                    icon: const Icon(Icons.today, size: 24),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    onPressed: () => _showOptionsMenu(context),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
