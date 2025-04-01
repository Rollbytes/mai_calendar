import 'package:flutter_bloc/flutter_bloc.dart';

import 'sf_calendar_date_picker_state.dart';

class CalendarDatePickerCubit extends Cubit<SfCalendarDatePickerState> {
  CalendarDatePickerCubit() : super(SfCalendarDatePickerState.initial());

  void updateDisplayDateInMonthView(List<DateTime> visibleDates) {
    if (visibleDates.isNotEmpty) {
      final currentDate = visibleDates.length > 1 ? visibleDates[visibleDates.length ~/ 2] : visibleDates.first;
      emit(state.copyWith(currentDate: currentDate));
    }
  }

  void updateDisplayDateInWeekView(List<DateTime> visibleDates) {
    if (visibleDates.isNotEmpty) {
      final currentDate = visibleDates.length > 1 ? visibleDates[visibleDates.length ~/ 2] : visibleDates.first;
      emit(state.copyWith(currentDate: currentDate));
    }
  }

  void updateDisplayInDayView(List<DateTime> visibleDates) {
    if (visibleDates.isNotEmpty) {
      final currentDate = visibleDates[0];
      emit(state.copyWith(currentDate: currentDate));
    }
  }

  void updateDisplayInScheduleView(DateTime selectedDate) {
    emit(state.copyWith(currentDate: selectedDate));
  }

  void updateDisplayInDatePicker(DateTime selectedDate) {
    emit(state.copyWith(currentDate: selectedDate));
  }

  void toggleDatePickerExpanded(bool isExpanded) {
    emit(state.copyWith(isDatePickerExpanded: isExpanded));
  }
}
