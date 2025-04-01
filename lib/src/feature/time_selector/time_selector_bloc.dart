import 'package:flutter_bloc/flutter_bloc.dart';
import 'time_selector_event.dart';
import 'time_selector_state.dart';

class TimeSelectorBloc extends Bloc<TimeSelectorEvent, TimeSelectorState> {
  TimeSelectorBloc({DateTime? initialDate})
      : super(initialDate != null
            ? TimeSelectorState(
                selectedStartTime: initialDate,
                calendarTimePickerDisplayedMonthDate: initialDate,
              )
            : TimeSelectorState.initial()) {
    on<ToggleEndTime>(_onToggleEndTime);
    on<ToggleCalendarDatePicker>(_onToggleTimeSelector);
    on<UpdateStartTime>(_onUpdateStartTime);
    on<UpdateEndTime>(_onUpdateEndTime);
    on<ToggleShowTimeButton>(_onToggleShowTimeButton);
    on<UpdateDisplayedMonthDate>(_onUpdateDisplayedMonthDate);
    on<ToggleIsSelectingEndDate>(_onToggleIsSelectingEndDate);
  }

  void _onToggleEndTime(ToggleEndTime event, Emitter<TimeSelectorState> emit) {
    if (!event.hasEndTime) {
      emit(state.copyWith(
        hasEndTime: event.hasEndTime,
        selectedEndTime: null,
      ));
    } else {
      // 當開啟指定結束日期時，設定結束時間為開始時間加上一小時
      emit(state.copyWith(
        hasEndTime: event.hasEndTime,
        selectedEndTime: state.selectedStartTime.add(const Duration(hours: 1)),
      ));
    }
  }

  void _onToggleTimeSelector(ToggleCalendarDatePicker event, Emitter<TimeSelectorState> emit) {
    emit(state.copyWith(isShowTimeSelector: event.isShow, selectedStartTime: state.selectedStartTime, selectedEndTime: state.selectedEndTime));
  }

  void _onUpdateStartTime(UpdateStartTime event, Emitter<TimeSelectorState> emit) {
    if (state.hasEndTime && state.selectedEndTime != null) {
      // 先更新開始時間
      emit(state.copyWith(selectedStartTime: event.startTime, selectedEndTime: state.selectedEndTime));

      // 如果是從時間選擇器更新的，則調整結束時間的時間部分，但保持日期不變
      if (event.updateEndTime) {
        // 獲取duration的總分鐘數
        final durationMinutes = state.duration.inMinutes;

        // 計算新的小時和分鐘
        final startTimeMinutes = event.startTime.hour * 60 + event.startTime.minute;
        final newEndTimeMinutes = startTimeMinutes + durationMinutes;

        // 計算新的小時和分鐘，處理可能超過24小時的情況
        final newHour = (newEndTimeMinutes ~/ 60) % 24;
        final newMinute = newEndTimeMinutes % 60;

        // 計算可能需要增加的天數
        final additionalDays = (newEndTimeMinutes ~/ 60) ~/ 24;

        // 創建新的結束時間，保持原有的年月日，只更新時間
        final newEndTime = DateTime(
          state.selectedEndTime!.year,
          state.selectedEndTime!.month,
          state.selectedEndTime!.day + (additionalDays > 0 ? additionalDays : 0),
          newHour,
          newMinute,
        );

        emit(state.copyWith(selectedEndTime: newEndTime));
      }
    } else {
      emit(state.copyWith(selectedStartTime: event.startTime, selectedEndTime: null));
    }
  }

  void _onUpdateEndTime(UpdateEndTime event, Emitter<TimeSelectorState> emit) {
    if (state.hasEndTime) {
      if (event.updateDuration && event.endTime != null) {
        // 計算新的duration
        final startTimeMinutes = state.selectedStartTime.hour * 60 + state.selectedStartTime.minute;
        final endTimeMinutes = event.endTime!.hour * 60 + event.endTime!.minute;

        int diffMinutes = endTimeMinutes >= startTimeMinutes ? endTimeMinutes - startTimeMinutes : endTimeMinutes + (24 * 60) - startTimeMinutes;

        final duration = Duration(minutes: diffMinutes);
        emit(state.copyWith(selectedEndTime: event.endTime, duration: duration));
      } else {
        // 不更新duration
        emit(state.copyWith(selectedEndTime: event.endTime));
      }
    } else {
      emit(state.copyWith(selectedEndTime: null));
    }
  }

  void _onToggleShowTimeButton(ToggleShowTimeButton event, Emitter<TimeSelectorState> emit) {
    emit(state.copyWith(showTimeButton: event.showTimeButton, selectedStartTime: state.selectedStartTime, selectedEndTime: state.selectedEndTime));
  }

  void _onUpdateDisplayedMonthDate(UpdateDisplayedMonthDate event, Emitter<TimeSelectorState> emit) {
    emit(state.copyWith(
        calendarTimePickerDisplayedMonthDate: event.displayedMonthDate, selectedStartTime: event.displayedMonthDate, selectedEndTime: state.selectedEndTime));
  }

  void _onToggleIsSelectingEndDate(ToggleIsSelectingEndDate event, Emitter<TimeSelectorState> emit) {
    emit(state.copyWith(isSelectingEndDate: event.isSelectingEndDate, selectedStartTime: state.selectedStartTime, selectedEndTime: state.selectedEndTime));
  }
}
