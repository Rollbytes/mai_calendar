import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeButton extends StatelessWidget {
  final DateTime time;
  final bool isStartTime;
  final bool showTimeButton;
  final Function(BuildContext context, bool isSetStartTime) onDatePressed;
  final Function(BuildContext context, bool isSetStartTime) onTimePressed;
  final String Function(DateTime)? formatDate;
  final double? dateButtonWidth;

  const TimeButton({
    super.key,
    required this.time,
    required this.isStartTime,
    required this.showTimeButton,
    required this.onDatePressed,
    required this.onTimePressed,
    this.formatDate,
    this.dateButtonWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 155,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              padding: EdgeInsets.zero,
            ),
            onPressed: () => onDatePressed(context, isStartTime),
            child: Container(
              alignment: showTimeButton ? Alignment.centerLeft : Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  formatDate?.call(time) ?? _defaultFormatDate(time),
                  style: const TextStyle(color: Colors.black45, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
        if (showTimeButton)
          SizedBox(
            width: 155,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              onPressed: () => onTimePressed(context, isStartTime),
              child: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 10),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    DateFormat('a h:mm', 'zh_TW').format(time),
                    style: const TextStyle(color: Colors.black45, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          )
      ],
    );
  }

  String _defaultFormatDate(DateTime date) {
    return DateFormat('MM/dd').format(date);
  }
}
