import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../models/index.dart';

/// 適配器類，用於將 CalendarEvent 轉換為 Syncfusion Calendar 可用的格式
class MaiCalendarDataSource extends CalendarDataSource {
  /// 預設顏色列表
  static final Map<String, Color> _predefinedColors = {
    '#FF6B6B': const Color(0xFFFF6B6B), // 紅色
    '#FF7878': const Color(0xFFFF7878), // 粉紅色
    '#FF8C66': const Color(0xFFFF8C66), // 橙色
    '#FFA366': const Color(0xFFFFA366), // 杏橙色
    '#FFC847': const Color(0xFFFFC847), // 明亮黃
    '#66C589': const Color(0xFF66C589), // 翠綠色
    '#6B8EFF': const Color(0xFF6B8EFF), // 湛藍色
    '#759AD4': const Color(0xFF759AD4), // 淡藍色
    '#937ACD': const Color(0xFF937ACD), // 紫色
    '#B98ED8': const Color(0xFFB98ED8), // 薰衣草紫
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

    // 首先檢查是否是預定義的顏色
    final colorKey = colorString.length >= 7 ? colorString.substring(0, 7) : colorString;
    if (_predefinedColors.containsKey(colorKey)) {
      return _predefinedColors[colorKey]!;
    }

    // 處理十六進制顏色格式 #RRGGBBAA 或 #RRGGBB
    String hexColor = colorString.replaceAll('#', '');
    try {
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
    } catch (e) {
      print('顏色解析錯誤: $colorString, $e');
      return Colors.blue; // 解析出錯時返回默認顏色
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
