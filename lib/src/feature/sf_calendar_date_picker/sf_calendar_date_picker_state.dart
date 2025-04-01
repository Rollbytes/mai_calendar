import 'package:equatable/equatable.dart';

class SfCalendarDatePickerState extends Equatable {
  final DateTime currentDate;

  final bool isDatePickerExpanded;

  const SfCalendarDatePickerState({
    required this.currentDate,
    this.isDatePickerExpanded = false,
  });

  factory SfCalendarDatePickerState.initial() {
    final now = DateTime.now();
    return SfCalendarDatePickerState(currentDate: now);
  }

  SfCalendarDatePickerState copyWith({
    DateTime? currentDate,
    bool? isDatePickerExpanded,
  }) {
    return SfCalendarDatePickerState(
      currentDate: currentDate ?? this.currentDate,
      isDatePickerExpanded: isDatePickerExpanded ?? this.isDatePickerExpanded,
    );
  }

  @override
  List<Object> get props => [currentDate, isDatePickerExpanded];
}
