import 'package:equatable/equatable.dart';

class TimeSelectorState extends Equatable {
  final DateTime selectedStartTime;
  final DateTime? selectedEndTime;
  final bool isAllDay;
  final bool hasEndTime;
  final bool isShowTimeSelector;
  final bool showTimeButton;
  final DateTime calendarTimePickerDisplayedMonthDate;
  final bool isSelectingEndDate;
  final Duration duration;

  const TimeSelectorState({
    required this.selectedStartTime,
    this.selectedEndTime,
    this.isAllDay = false,
    this.hasEndTime = false,
    this.isShowTimeSelector = false,
    this.showTimeButton = true,
    required this.calendarTimePickerDisplayedMonthDate,
    this.isSelectingEndDate = false,
    this.duration = const Duration(hours: 1),
  });

  factory TimeSelectorState.initial() {
    return TimeSelectorState(
      selectedStartTime: DateTime.now(),
      calendarTimePickerDisplayedMonthDate: DateTime.now(),
    );
  }

  TimeSelectorState copyWith({
    DateTime? selectedStartTime,
    DateTime? selectedEndTime,
    bool? hasEndTime,
    bool? isShowTimeSelector,
    bool? showTimeButton,
    DateTime? calendarTimePickerDisplayedMonthDate,
    bool? isSelectingEndDate,
    Duration? duration,
    bool? isAllDay,
  }) {
    return TimeSelectorState(
      selectedStartTime: selectedStartTime ?? this.selectedStartTime,
      selectedEndTime: selectedEndTime,
      hasEndTime: hasEndTime ?? this.hasEndTime,
      isShowTimeSelector: isShowTimeSelector ?? this.isShowTimeSelector,
      showTimeButton: showTimeButton ?? this.showTimeButton,
      calendarTimePickerDisplayedMonthDate: calendarTimePickerDisplayedMonthDate ?? this.calendarTimePickerDisplayedMonthDate,
      isSelectingEndDate: isSelectingEndDate ?? this.isSelectingEndDate,
      duration: duration ?? this.duration,
      isAllDay: isAllDay ?? this.isAllDay,
    );
  }

  @override
  List<Object?> get props => [
        selectedStartTime,
        selectedEndTime,
        hasEndTime,
        isShowTimeSelector,
        showTimeButton,
        calendarTimePickerDisplayedMonthDate,
        isSelectingEndDate,
        duration,
        isAllDay,
      ];
}
