import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mai_calendar/src/feature/time_selector/time_button.dart';
import 'time_selector_bloc.dart';
import 'time_selector_state.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

import 'time_selector_event.dart';

class TimeSelector extends StatefulWidget {
  const TimeSelector({super.key, this.timeSelectorBloc});
  final TimeSelectorBloc? timeSelectorBloc;

  @override
  State<TimeSelector> createState() => _TimeSelectorState();
}

class _TimeSelectorState extends State<TimeSelector> {
  late final TimeSelectorBloc _timeSelectorBloc;
  @override
  void initState() {
    super.initState();
    _timeSelectorBloc = widget.timeSelectorBloc ?? TimeSelectorBloc();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimeSelectorBloc, TimeSelectorState>(
      bloc: _timeSelectorBloc,
      builder: (context, state) {
        return Column(
          children: [
            _buildSelectTimeSection(context, state),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeToggleButtons(context, state),
                const SizedBox(width: 16),
                _buildCalendarIconButton(context, state),
              ],
            ),
            if (state.isShowTimeSelector) _buildCalendarDatePicker(context, state),
          ],
        );
      },
    );
  }

  Widget _buildSelectTimeSection(BuildContext context, TimeSelectorState state) {
    if (state.hasEndTime && !state.showTimeButton) {
      return Container(
        alignment: Alignment.center,
        width: double.maxFinite,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: TimeButton(
                time: state.selectedStartTime,
                isStartTime: true,
                formatDate: (date) => DateFormat('MM月dd日EEEE', 'zh_TW').format(date),
                showTimeButton: state.showTimeButton,
                onDatePressed: (context, isSetStartTime) => _showDatePickerDialog(context: context, state: state, isSetStartTime: isSetStartTime),
                onTimePressed: (context, isSetStartTime) => _showTimePickerDialog(context: context, state: state, isSetStartTime: isSetStartTime),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TimeButton(
                time: state.selectedEndTime!,
                formatDate: (date) => DateFormat('MM月dd日EEEE', 'zh_TW').format(date),
                isStartTime: false,
                showTimeButton: state.showTimeButton,
                onDatePressed: (context, isSetStartTime) => _showDatePickerDialog(context: context, state: state, isSetStartTime: isSetStartTime),
                onTimePressed: (context, isSetStartTime) => _showTimePickerDialog(context: context, state: state, isSetStartTime: isSetStartTime),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        alignment: Alignment.center,
        width: double.maxFinite,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TimeButton(
              time: state.selectedStartTime,
              isStartTime: true,
              formatDate: (date) => DateFormat('MM月dd日EEEE', 'zh_TW').format(date),
              showTimeButton: state.showTimeButton,
              onDatePressed: (context, isSetStartTime) => _showDatePickerDialog(context: context, state: state, isSetStartTime: isSetStartTime),
              onTimePressed: (context, isSetStartTime) => _showTimePickerDialog(context: context, state: state, isSetStartTime: isSetStartTime),
              dateButtonWidth: state.showTimeButton ? null : MediaQuery.of(context).size.width - 32,
            ),
            if (state.hasEndTime)
              TimeButton(
                time: state.selectedEndTime!,
                formatDate: (date) => DateFormat('MM月dd日EEEE', 'zh_TW').format(date),
                isStartTime: false,
                showTimeButton: state.showTimeButton,
                onDatePressed: (context, isSetStartTime) => _showDatePickerDialog(context: context, state: state, isSetStartTime: isSetStartTime),
                onTimePressed: (context, isSetStartTime) => _showTimePickerDialog(context: context, state: state, isSetStartTime: isSetStartTime),
                dateButtonWidth: state.showTimeButton ? null : MediaQuery.of(context).size.width - 32,
              ),
          ],
        ),
      );
    }
  }

  Widget _buildCalendarIconButton(BuildContext context, TimeSelectorState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: state.isShowTimeSelector ? Colors.grey.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: GestureDetector(
        onTap: () => _timeSelectorBloc.add(ToggleCalendarDatePicker(!state.isShowTimeSelector)),
        child: Row(
          children: [
            Icon(Icons.calendar_month_outlined, size: 22),
            const SizedBox(width: 2),
            Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeToggleButtons(BuildContext context, TimeSelectorState state) {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(0),
            margin: const EdgeInsets.all(0),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "指定結束日期",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 30,
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Switch(value: state.hasEndTime, onChanged: (value) => _timeSelectorBloc.add(ToggleEndTime(value))),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(0),
            margin: const EdgeInsets.all(0),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "指定時間",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 30,
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Switch(
                      value: state.showTimeButton,
                      onChanged: (value) => _timeSelectorBloc.add(ToggleShowTimeButton(value)),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDatePickerDialog({required BuildContext context, required TimeSelectorState state, required bool isSetStartTime}) async {
    if (!isSetStartTime && !state.hasEndTime) return;

    final currentSelectedTime = isSetStartTime ? state.selectedStartTime : state.selectedEndTime;
    final DateTime? result = await showDatePicker(
        context: context, initialDate: currentSelectedTime ?? state.selectedStartTime, firstDate: DateTime(1900), lastDate: DateTime(2100));

    if (result != null && result != currentSelectedTime) {
      if (isSetStartTime) {
        final newStartTime = DateTime(
          result.year,
          result.month,
          result.day,
          state.selectedStartTime.hour,
          state.selectedStartTime.minute,
        );
        _timeSelectorBloc.add(UpdateStartTime(newStartTime, updateEndTime: false));

        // 如果有結束時間且結束時間早於新的開始時間，調整結束時間
        if (state.hasEndTime && state.selectedEndTime != null && state.selectedEndTime!.isBefore(newStartTime)) {
          _timeSelectorBloc.add(UpdateEndTime(newStartTime, updateDuration: false));
        }
      } else {
        final newEndTime = DateTime(
          result.year,
          result.month,
          result.day,
          state.selectedEndTime?.hour ?? state.selectedStartTime.hour,
          state.selectedEndTime?.minute ?? state.selectedStartTime.minute,
        );

        // 檢查新的結束時間是否合法
        if (newEndTime.isBefore(state.selectedStartTime)) {
          _timeSelectorBloc.add(UpdateEndTime(state.selectedStartTime, updateDuration: false));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('結束時間不得早於開始時間')),
          );
        } else {
          _timeSelectorBloc.add(UpdateEndTime(newEndTime, updateDuration: false));
        }
      }
    }
  }

  Future<void> _showTimePickerDialog({required BuildContext context, required TimeSelectorState state, required bool isSetStartTime}) async {
    final currentSelectedTime = isSetStartTime ? state.selectedStartTime : state.selectedEndTime ?? DateTime.now();
    final TimeOfDay initTime = TimeOfDay.fromDateTime(currentSelectedTime);
    final TimeOfDay? result = await showTimePicker(context: context, initialTime: initTime);

    if (result != null) {
      final DateTime resultDateTime = DateTime(
        currentSelectedTime.year,
        currentSelectedTime.month,
        currentSelectedTime.day,
        result.hour,
        result.minute,
      );

      if (isSetStartTime) {
        // 設置開始時間時，如果結束時間早於新的開始時間，則自動調整結束時間
        _timeSelectorBloc.add(UpdateStartTime(resultDateTime, updateEndTime: true));

        if (state.hasEndTime && state.selectedEndTime != null && state.selectedEndTime!.isBefore(resultDateTime)) {
          _timeSelectorBloc.add(UpdateEndTime(resultDateTime));
        }
      } else {
        // 設置結束時間時，如果新的結束時間早於開始時間，則自動調整為開始時間
        if (resultDateTime.isBefore(state.selectedStartTime)) {
          _timeSelectorBloc.add(UpdateEndTime(state.selectedStartTime));
        } else {
          _timeSelectorBloc.add(UpdateEndTime(resultDateTime));
        }
      }
    }
  }

  Widget _buildCalendarDatePicker(BuildContext context, TimeSelectorState state) {
    return Stack(
      children: [
        Listener(
          onPointerDown: (PointerDownEvent event) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: CalendarDatePicker2(
            displayedMonthDate: state.calendarTimePickerDisplayedMonthDate,
            onDisplayedMonthChanged: (value) => _timeSelectorBloc.add(UpdateDisplayedMonthDate(value)),
            onValueChanged: (dates) => _handleDateSelection(context: context, state: state, dates: dates),
            config: CalendarDatePicker2Config(
              dynamicCalendarRows: true,
              animateToDisplayedMonthDate: false,
              allowSameValueSelection: true,
              centerAlignModePicker: true,
              currentDate: DateTime.now(),
              calendarViewMode: CalendarDatePicker2Mode.day,
              calendarType: state.hasEndTime ? CalendarDatePicker2Type.range : CalendarDatePicker2Type.single,
              selectedDayHighlightColor: Theme.of(context).primaryColor,
              weekdayLabels: ['日', '一', '二', '三', '四', '五', '六'],
            ),
            value: getValidDateRange(state),
          ),
        ),
        Positioned(
          top: 2,
          right: 40,
          child: TextButton(
            onPressed: () {
              _timeSelectorBloc.add(UpdateDisplayedMonthDate(DateTime.now()));
            },
            child: Icon(
              Icons.today_outlined,
              size: 20,
              color: Colors.grey.shade500,
            ),
          ),
        ),
      ],
    );
  }

  List<DateTime?> getValidDateRange(TimeSelectorState state) {
    if (!state.hasEndTime) {
      return [state.selectedStartTime];
    }

    if (state.selectedEndTime == null) {
      return [state.selectedStartTime];
    }

    if (state.selectedEndTime!.isBefore(state.selectedStartTime)) {
      return [state.selectedStartTime, state.selectedStartTime];
    }

    return [state.selectedStartTime, state.selectedEndTime];
  }

  void _handleDateSelection({required BuildContext context, required TimeSelectorState state, required List<DateTime> dates}) {
    if (dates.isEmpty) return;

    if (state.hasEndTime) {
      if (!state.isSelectingEndDate) {
        _timeSelectorBloc.add(ToggleIsSelectingEndDate(true));
        _timeSelectorBloc.add(UpdateStartTime(dates.first));
      } else {
        final endDate = dates.first;
        if (endDate.isBefore(state.selectedStartTime)) {
          _timeSelectorBloc.add(UpdateEndTime(state.selectedStartTime));
          _timeSelectorBloc.add(UpdateStartTime(endDate));
        } else {
          _timeSelectorBloc.add(UpdateEndTime(endDate));
        }
        _timeSelectorBloc.add(ToggleIsSelectingEndDate(false));
      }
    } else {
      _timeSelectorBloc.add(UpdateStartTime(dates.first));
    }
  }
}
