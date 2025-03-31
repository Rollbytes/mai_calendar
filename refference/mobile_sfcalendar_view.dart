import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:lunar/calendar/Lunar.dart';
import 'package:mai_api/client.dart';
import 'package:mai_app/modules/calendar/src/core/models/calendar_appointment_model.dart';
import 'package:mai_app/modules/calendar/src/core/views/mobile_calendar_appointment_editor.dart';
import 'package:mai_app/modules/calendar/src/core/widget/sf_calendar_date_picker/sf_calendar_date_picker_cubit.dart';
import '../basic_calendar_bloc.dart';
import '../basic_calendar_event.dart';
import '../basic_calendar_state.dart';
import '../widget/sf_calendar_date_picker/sf_calendar_date_picker_state.dart';
import '../widget/sf_calendar_date_picker/sf_calendar_date_picker.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import 'mobile_calendar_appointment_of_day_view.dart';
import 'mobile_sfcalendar_viewtype_appointment.dart';

enum CalendarType { global, board, table, search }

class MobileSfCalendarView<T extends BasicCalendarBloc<S>, S extends BasicCalendarState> extends StatefulWidget {
  const MobileSfCalendarView(
      {super.key,
      required this.calendarType,
      this.maiTable,
      this.onOrderButtonPressed,
      this.onCalendarEventButtonPressed,
      this.board,
      this.onPressMenu,
      this.onSearchButtonPressed,
      this.dataSource,
      required this.bloc,
      this.onGenerateTestDataButtonPressed,
      this.onCoachHolidayButtonPressed,
      this.onCoachDataButtonPressed,
      this.onMenuItemSelected});
  final CalendarType calendarType;

  final Maitable? maiTable;
  final VoidCallback? onOrderButtonPressed;
  final VoidCallback? onCalendarEventButtonPressed;
  final VoidCallback? onGenerateTestDataButtonPressed;
  final VoidCallback? onCoachHolidayButtonPressed;
  final VoidCallback? onCoachDataButtonPressed;
  final VoidCallback? onPressMenu;
  final VoidCallback? onSearchButtonPressed;
  final Board? board;
  final CalendarAppointmentSource? dataSource;
  final T bloc;
  final Function(String)? onMenuItemSelected;

  static void showOptionsMenu<T extends BasicCalendarBloc<S>, S extends BasicCalendarState>(BuildContext context,
      {String? maidbId, CalendarType? calendarType, Function(String)? onMenuItemSelected}) {
    showMenu<String>(
      context: context,
      position: calendarType == CalendarType.table
          ? const RelativeRect.fromLTRB(100, 210, 0, 0)
          : calendarType == CalendarType.search
              ? const RelativeRect.fromLTRB(95, 160, 0, 0)
              : const RelativeRect.fromLTRB(100, 110, 0, 0),
      items: [
        if (calendarType != CalendarType.search)
          PopupMenuItem<String>(
            child: BlocProvider.value(
              value: context.read<T>(),
              child: BlocBuilder<T, S>(
                builder: (context, state) {
                  return Row(
                    children: [
                      const Text('行事曆視角'),
                      const Spacer(),
                      PopupMenuButton<int>(
                        initialValue: context.read<T>().allowedViewsMobile.indexOf(state.currentCalendarView),
                        onSelected: (int value) {
                          context.read<T>().add(CalendarViewTypeChanged(value));
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                          for (int i = 0; i < context.read<T>().allowedViewsMobile.length; i++)
                            PopupMenuItem<int>(
                              value: i,
                              child: Text(context.read<T>().getViewNameZhTW(context.read<T>().allowedViewsMobile[i])),
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
                              Text(context.read<T>().getViewNameZhTW(state.currentCalendarView)),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        const PopupMenuItem<String>(enabled: false, height: 8, child: SizedBox()),
        if (calendarType == CalendarType.global)
          PopupMenuItem<String>(
            value: 'generate_diving_tables',
            child: const Row(
              children: [
                Icon(Icons.data_array, size: 20),
                SizedBox(width: 8),
                Text('產生潛水訂單測試表格'),
              ],
            ),
          ),
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
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          child: BlocProvider.value(
            value: context.read<T>(),
            child: BlocBuilder<T, S>(
              builder: (context, state) {
                return Row(
                  children: [
                    const Text('農曆日期'),
                    const Spacer(),
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: state.showLunarDate,
                        activeTrackColor: Theme.of(context).colorScheme.primary,
                        onChanged: (value) {
                          context.read<T>().add(ToggleLunarDate(value));
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        PopupMenuItem<String>(
          child: BlocProvider.value(
            value: context.read<T>(),
            child: BlocBuilder<T, S>(
              builder: (context, state) {
                return Row(
                  children: [
                    const Text('行程顯示數量'),
                    const Spacer(),
                    PopupMenuButton<int>(
                      initialValue: state.appointmentDisplayCount,
                      onSelected: (int value) {
                        context.read<T>().add(UpdateAppointmentDisplayCount(value));
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                        for (int i = 1; i <= 5; i++)
                          PopupMenuItem<int>(
                            value: i,
                            child: Text('$i'),
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
                            Text('${state.appointmentDisplayCount}'),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    ).then((value) {
      if (value != null && value == 'generate_diving_tables' && calendarType == CalendarType.global && onMenuItemSelected != null) {
        onMenuItemSelected(value);
      }
    });
  }

  @override
  State<MobileSfCalendarView<T, S>> createState() => _MobileSfCalendarViewState<T, S>();
}

class _MobileSfCalendarViewState<T extends BasicCalendarBloc<S>, S extends BasicCalendarState> extends State<MobileSfCalendarView<T, S>> {
  late T _calendarBloc;

  late final CalendarDatePickerCubit _calendarDatePickerCubit;
  final SheetController _sheetController = SheetController();
  final DateRangePickerController _dateRangePickerController = DateRangePickerController();

  final DateTime _now = DateTime.now();
  late DateTime _displayDate;
  int _numberOfWeeksInView = 6;
  final GlobalKey _appBarKey = GlobalKey();
  final ScrollController scrollController = ScrollController();

  final scheduleViewSettings = const ScheduleViewSettings(
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
      appointmentTextStyle: TextStyle(fontSize: 14));

  @override
  void initState() {
    super.initState();
    _displayDate = DateTime(_now.year, _now.month, 1);
    _calendarDatePickerCubit = context.read<CalendarDatePickerCubit>();
    _calendarBloc = widget.bloc;
    _listenScheduleView();
  }

  @override
  void dispose() {
    super.dispose();
    _dateRangePickerController.dispose();
    _sheetController.dispose();
  }

  ///[onViewChange] will provide different [viewChangedDetails] in individual view,
  ///only[CalendarView.schedule]can not get right date when scrolling view.
  ///so use [addPropertyChangedListener] get [displayDate].
  void _listenScheduleView() {
    _calendarBloc.sfCalendarController.addPropertyChangedListener(
      (_) {
        if (_calendarBloc.state.currentCalendarView == CalendarView.schedule) {
          _calendarDatePickerCubit.updateDisplayInScheduleView(_calendarBloc.sfCalendarController.displayDate ?? DateTime.now());

          _dateRangePickerController.displayDate = _calendarBloc.sfCalendarController.displayDate;
        }
      },
    );
  }

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
                displayDate: _displayDate,
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
      _calendarBloc.sfCalendarController.displayDate = arg.value;
      dialogContext.read<CalendarDatePickerCubit>().updateDisplayInDatePicker(arg.value);
      Navigator.of(context).pop();
    }
  }

  void _onCalendarViewChanged(ViewChangedDetails viewChangedDetails, BuildContext context) {
    if (viewChangedDetails.visibleDates.isNotEmpty) {
      switch (_calendarBloc.state.currentCalendarView) {
        case CalendarView.month:
          context.read<CalendarDatePickerCubit>().updateDisplayDateInMonthView(viewChangedDetails.visibleDates);
          _dateRangePickerController.displayDate = _calendarBloc.sfCalendarController.displayDate;
          //make datePicker view sync after swipe//
          _dateRangePickerController.selectedDate = _dateRangePickerController.displayDate;
          break;
        case CalendarView.week:
          context.read<CalendarDatePickerCubit>().updateDisplayDateInWeekView(viewChangedDetails.visibleDates);
          _dateRangePickerController.displayDate = _calendarBloc.sfCalendarController.displayDate;
        case CalendarView.day:
          context.read<CalendarDatePickerCubit>().updateDisplayInDayView(viewChangedDetails.visibleDates);
          _dateRangePickerController.displayDate = _calendarBloc.sfCalendarController.displayDate;
        default:
          _dateRangePickerController.displayDate = _calendarBloc.sfCalendarController.displayDate;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<T, S>(
      bloc: _calendarBloc,
      builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              Column(
                children: [
                  _buildAppBar(context, key: _appBarKey),
                  Expanded(
                    child: SfCalendar(
                        onTap: (calendarTapDetails) {
                          final isMonthView =
                              calendarTapDetails.targetElement == CalendarElement.calendarCell && _calendarBloc.sfCalendarController.view == CalendarView.month;
                          if (isMonthView && !state.isShowAddCalendarItemView) {
                            _showMonthEventsBottomSheet(context);
                          }
                        },
                        headerHeight: 0,
                        timeSlotViewSettings: const TimeSlotViewSettings(
                          timeIntervalHeight: 60,
                          timeTextStyle: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                          timeRulerSize: 70,
                        ),
                        cellBorderColor: Colors.grey[400],
                        resourceViewHeaderBuilder: (context, details) => Text(details.resource.displayName),
                        resourceViewSettings:
                            const ResourceViewSettings(showAvatar: true, size: 75, visibleResourceCount: 5, displayNameTextStyle: TextStyle(fontSize: 24)),
                        dataSource: widget.dataSource ?? CalendarAppointmentSource(state.calendarAppointments),
                        monthCellBuilder: (context, detail) => _buildMonthCell(context, detail),
                        allowAppointmentResize: true,
                        appointmentBuilder: (context, details) => MobileCalendarViewTypeAppointment(
                            basicCalendarBloc: _calendarBloc, viewType: context.read<T>().sfCalendarController.view, details: details),
                        showDatePickerButton: true,
                        showTodayButton: true,
                        firstDayOfWeek: 1,
                        allowViewNavigation: false,
                        showWeekNumber: false,
                        view: state.currentCalendarView,
                        allowedViews: _calendarBloc.allowedViewsMobile,
                        scheduleViewSettings: scheduleViewSettings,
                        monthViewSettings: MonthViewSettings(
                          showAgenda: false,
                          appointmentDisplayCount: state.appointmentDisplayCount,
                          showTrailingAndLeadingDates: true,
                          numberOfWeeksInView: _numberOfWeeksInView,
                          navigationDirection: MonthNavigationDirection.horizontal,
                          dayFormat: 'EEE',
                          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                        ),
                        controller: _calendarBloc.sfCalendarController,
                        onViewChanged: (viewChangedDetails) => _onCalendarViewChanged(viewChangedDetails, context)),
                  ),
                ],
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: SpeedDial(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  icon: Icons.add,
                  activeIcon: Icons.close,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  children: [
                    if (widget.onGenerateTestDataButtonPressed != null)
                      SpeedDialChild(
                        child: const Icon(Icons.data_array),
                        label: '新增潛水資料表',
                        onTap: widget.onGenerateTestDataButtonPressed,
                      ),
                    if (widget.onCoachHolidayButtonPressed != null)
                      SpeedDialChild(
                        child: const Icon(Icons.event_busy),
                        label: '新增教練休假表',
                        onTap: widget.onCoachHolidayButtonPressed,
                      ),
                    if (widget.onCoachDataButtonPressed != null)
                      SpeedDialChild(
                        child: const Icon(Icons.person),
                        label: '新增教練資料表',
                        onTap: widget.onCoachDataButtonPressed,
                      ),
                    SpeedDialChild(
                      child: const Icon(Icons.event),
                      label: '新增行程',
                      onTap: widget.onCalendarEventButtonPressed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMonthCell(BuildContext context, MonthCellDetails details) {
    final lunarDate = Lunar.fromDate(details.date);
    final lunarDay = lunarDate.getDay();
    final lunarMonth = lunarDate.getMonth();

    return BlocBuilder<T, S>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(width: 0.8, color: Colors.grey.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${details.date.day}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: (details.date.day == _now.day && details.date.month == _now.month && details.date.year == _now.year)
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: (details.date.day == _now.day && details.date.month == _now.month && details.date.year == _now.year)
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
              ),
              if (state.showLunarDate)
                Text(
                  "$lunarMonth/$lunarDay",
                  style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, {Key? key}) {
    return BlocBuilder<CalendarDatePickerCubit, SfCalendarDatePickerState>(
      builder: (context, dateState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (widget.calendarType == CalendarType.global)
                        IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () {
                            widget.onPressMenu?.call();
                          },
                        ),
                      SizedBox(
                        key: key,
                        child: TextButton(
                          onPressed: () {
                            _calendarDatePickerCubit.toggleDatePickerExpanded(true);
                            showCalendarDatePicker(context, _calendarBloc.sfCalendarController.view ?? CalendarView.month);
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
                    if (widget.calendarType == CalendarType.search)
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: BlocBuilder<T, S>(
                          builder: (context, state) {
                            return PopupMenuButton<int>(
                              initialValue: _calendarBloc.allowedViewsMobile.indexOf(state.currentCalendarView),
                              onSelected: (int value) {
                                _calendarBloc.add(CalendarViewTypeChanged(value));
                              },
                              itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                                for (int i = 0; i < _calendarBloc.allowedViewsMobile.length; i++)
                                  PopupMenuItem<int>(
                                    value: i,
                                    child: Text(_calendarBloc.getViewNameZhTW(_calendarBloc.allowedViewsMobile[i])),
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
                                    Text(_calendarBloc.getViewNameZhTW(state.currentCalendarView)),
                                    const Icon(Icons.arrow_drop_down),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    // 搜尋按鈕功能不為null時，才顯示搜尋按鈕
                    if (widget.onSearchButtonPressed != null)
                      IconButton(
                        icon: const Icon(Icons.search),
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        onPressed: widget.onSearchButtonPressed,
                      ),
                    IconButton(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      onPressed: _jumpToToday,
                      icon: const Icon(Icons.today, size: 24),
                    ),
                    if (widget.calendarType == CalendarType.global || widget.calendarType == CalendarType.search || widget.calendarType == CalendarType.table)
                      IconButton(
                        icon: Icon(
                          Icons.more_vert,
                          size: 24,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          MobileSfCalendarView.showOptionsMenu<T, S>(context,
                              maidbId: widget.calendarType == CalendarType.board ? widget.board?.id : null,
                              calendarType: widget.calendarType,
                              onMenuItemSelected: widget.onMenuItemSelected);
                        },
                      ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _jumpToToday() {
    _calendarBloc.sfCalendarController.displayDate = _now;
    _dateRangePickerController.displayDate = _now;
    _dateRangePickerController.selectedDate = _now;
  }

  void _showMonthEventsBottomSheet(BuildContext bottomSheetContext) {
    Navigator.push(
      context,
      ModalSheetRoute(
        barrierColor: Colors.transparent,
        swipeDismissible: true,
        maintainState: false,
        fullscreenDialog: false,
        barrierDismissible: true,
        builder: (context) => BlocProvider.value(
          value: _calendarBloc,
          child: BlocBuilder<T, S>(
            bloc: _calendarBloc,
            builder: (context, state) {
              return MobileCalendarAppointmentOfDayView<T, S>(
                calendarBloc: _calendarBloc,
                calendarType: widget.calendarType,
                itemsOfDay: MobileCalendarAppointmentOfDayView.getItemsOfDay(
                  selectedDate: _calendarBloc.sfCalendarController.selectedDate,
                  items: _calendarBloc.state.calendarAppointments,
                ),
                selectedDate: _calendarBloc.sfCalendarController.selectedDate,
                fltButton: SpeedDial(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  icon: Icons.add,
                  foregroundColor: Colors.white,
                  activeIcon: Icons.close,
                  children: [
                    SpeedDialChild(
                        child: const Icon(Icons.event),
                        label: '新增行程',
                        onTap: () {
                          final route = ModalSheetRoute(
                            barrierDismissible: true,
                            swipeDismissible: true,
                            builder: (context) => MobileCalendarAppointmentEditor<T, S>(
                                basicCalendarBloc: _calendarBloc,
                                initialDateTime: _calendarBloc.sfCalendarController.selectedDate,
                                calendarType: widget.calendarType,
                                onBack: () => Navigator.of(context).pop(),
                                onSave: (base, board, table, timeColumn, datetimeData) {
                                  _calendarBloc.add(CalendarAppointmentCreateRequest(
                                      userBase: base,
                                      board: board,
                                      table: table,
                                      timeColumn: timeColumn,
                                      startTime: datetimeData.startTime,
                                      endTime: datetimeData.endTime,
                                      color: datetimeData.color,
                                      allDay: datetimeData.allDay,
                                      title: datetimeData.title,
                                      columnValues: MobileCalendarAppointmentEditor.currentTableExpansionBloc?.state.stagedColumnCellValue));
                                  Navigator.of(context).pop();
                                }),
                          );
                          Navigator.of(context).push(route);
                        }),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
