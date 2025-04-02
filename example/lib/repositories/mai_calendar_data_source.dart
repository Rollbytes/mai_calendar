import 'package:flutter/material.dart';
import 'package:mai_calendar/src/feature/color_picker/hex_color_adapter.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../models/index.dart';

/// 適配器類，用於將 CalendarEvent 轉換為 Syncfusion Calendar 可用的格式
class MaiCalendarDataSource extends CalendarDataSource {
  /// 預設顏色列表
  static final Map<String, String> predefinedColors = {
    '#FF6B6B': '紅色',
    '#FF7878': '粉紅色',
    '#FF8C66': '橙色',
    '#FFA366': '杏橙色',
    '#FFC847': '明亮黃',
    '#66C589': '翠綠色',
    '#6B8EFF': '湛藍色',
    '#759AD4': '淡藍色',
    '#937ACD': '紫色',
    '#B98ED8': '薰衣草紫',
  };

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
    return HexColor(event.color);
  }

  @override
  bool isAllDay(int index) {
    return _getCalendarEvent(index).isAllDay;
  }

  @override
  String? getNotes(int index) {
    // 返回事件的位置和來源信息，方便在 UI 中顯示
    final event = _getCalendarEvent(index);
    return event.locationPath;
  }

  @override
  String? getLocation(int index) {
    final event = _getCalendarEvent(index);
    return event.locationPath;
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
