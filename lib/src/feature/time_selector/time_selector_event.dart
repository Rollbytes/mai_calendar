abstract class TimeSelectorEvent {}

class ToggleEndTime extends TimeSelectorEvent {
  final bool hasEndTime;
  ToggleEndTime(this.hasEndTime);
}

class ToggleCalendarDatePicker extends TimeSelectorEvent {
  final bool isShow;
  ToggleCalendarDatePicker(this.isShow);
}

class ToggleShowTimeButton extends TimeSelectorEvent {
  final bool showTimeButton;
  ToggleShowTimeButton(this.showTimeButton);
}

class UpdateStartTime extends TimeSelectorEvent {
  final DateTime startTime;
  final bool updateEndTime;
  UpdateStartTime(this.startTime, {this.updateEndTime = false});
}

class UpdateEndTime extends TimeSelectorEvent {
  final DateTime? endTime;
  final bool updateDuration;
  UpdateEndTime(this.endTime, {this.updateDuration = true});
}

class UpdateDisplayedMonthDate extends TimeSelectorEvent {
  final DateTime displayedMonthDate;
  UpdateDisplayedMonthDate(this.displayedMonthDate);
}

class ToggleIsSelectingEndDate extends TimeSelectorEvent {
  final bool isSelectingEndDate;
  ToggleIsSelectingEndDate(this.isSelectingEndDate);
}