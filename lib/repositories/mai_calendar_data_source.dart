import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../models/index.dart';

/// 適配器類，用於將 CalendarEvent 轉換為 Syncfusion Calendar 可用的格式
class MaiCalendarDataSource extends CalendarDataSource {
  /// 創建一個數據源，用於將 CalendarEvent 集合設置到日曆中
  MaiCalendarDataSource(List<CalendarEvent> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return _getCalendarEvent(index).startTime;
  }

  @override
  DateTime getEndTime(int index) {
    final event = _getCalendarEvent(index);
    return event.endTime ?? event.startTime.add(const Duration(hours: 1));
  }

  @override
  String getSubject(int index) {
    final event = _getCalendarEvent(index);
    return event.title;
  }

  @override
  Color getColor(int index) {
    final event = _getCalendarEvent(index);
    return _parseColor(event.color);
  }

  @override
  bool isAllDay(int index) {
    return _getCalendarEvent(index).isAllDay;
  }

  @override
  String? getRecurrenceRule(int index) {
    // 目前 CalendarEvent 不支持重複規則
    return null;
  }

  @override
  String? getNotes(int index) {
    // 返回事件的位置和來源信息，方便在 UI 中顯示
    final event = _getCalendarEvent(index);
    return event.locationPath ?? event.sourceDescription;
  }

  @override
  String? getLocation(int index) {
    final event = _getCalendarEvent(index);
    return event.locationPath;
  }

  /// 將十六進制顏色字符串解析為 Color 對象
  Color _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) {
      return Colors.blue; // 默認顏色
    }

    // 處理十六進制顏色格式 #RRGGBBAA 或 #RRGGBB
    String hexColor = colorString.replaceAll('#', '');
    if (hexColor.length == 8) {
      // 如果包含透明度信息
      return Color(int.parse('0x$hexColor'));
    } else if (hexColor.length == 6) {
      // 如果沒有透明度信息，添加FF作為不透明
      return Color(int.parse('0xFF$hexColor'));
    } else {
      // 格式不正確，返回默認顏色
      return Colors.blue;
    }
  }

  /// 獲取指定索引的 CalendarEvent
  CalendarEvent _getCalendarEvent(int index) {
    final dynamic appointment = appointments![index];
    late final CalendarEvent calendarEvent;
    if (appointment is CalendarEvent) {
      calendarEvent = appointment;
    }
    return calendarEvent;
  }

  /// 獲取指定日期的事件
  List<CalendarEvent> getEventsForDate(DateTime date) {
    return appointments!
        .where((appointment) {
          final event = appointment as CalendarEvent;
          final startDate = DateTime(
            event.startTime.year,
            event.startTime.month,
            event.startTime.day,
          );
          final endDate = event.endTime != null
              ? DateTime(
                  event.endTime!.year,
                  event.endTime!.month,
                  event.endTime!.day,
                )
              : startDate;
          final targetDate = DateTime(date.year, date.month, date.day);

          // 檢查日期是否在事件範圍內
          return (targetDate.isAtSameMomentAs(startDate) ||
              targetDate.isAtSameMomentAs(endDate) ||
              (targetDate.isAfter(startDate) && targetDate.isBefore(endDate)));
        })
        .map((appointment) => appointment as CalendarEvent)
        .toList();
  }
}
