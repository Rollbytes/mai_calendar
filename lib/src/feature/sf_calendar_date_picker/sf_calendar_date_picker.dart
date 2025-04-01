import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class SfCalendarDatePicker extends StatelessWidget {
  final CalendarView currentView;
  final DateTime displayDate;
  final DateRangePickerController dateRangePickerController;
  final Function(DateRangePickerSelectionChangedArgs) onSelectionChanged;

  const SfCalendarDatePicker({
    super.key,
    required this.currentView,
    required this.displayDate,
    required this.dateRangePickerController,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SfDateRangePicker(
      key: const ValueKey('datePicker'),
      monthFormat: 'MM月',
      backgroundColor: Colors.transparent,
      showNavigationArrow: true,
      selectionMode: DateRangePickerSelectionMode.single,
      headerStyle: const DateRangePickerHeaderStyle(
        textAlign: TextAlign.center,
        backgroundColor: Colors.transparent,
      ),
      view: currentView == CalendarView.month ? DateRangePickerView.year : DateRangePickerView.month,
      showTodayButton: true,
      allowViewNavigation: currentView != CalendarView.month,
      initialDisplayDate: displayDate,
      initialSelectedDate: displayDate,
      controller: dateRangePickerController,
      navigationDirection: DateRangePickerNavigationDirection.horizontal,
      onSelectionChanged: onSelectionChanged,
    );
  }
}
