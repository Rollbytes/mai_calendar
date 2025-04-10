import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../feature/color_picker/hex_color_adapter.dart';
import '../models/calendar_models.dart';
import '../calendar_bloc/calendar_bloc.dart';
import 'mai_calendar_appointment_detail_view.dart';

/// 行事曆中事件項目的自定義顯示組件
class MaiCalendarAppointmentBuilder extends StatefulWidget {
  /// 當前視圖類型
  final CalendarView? viewType;

  /// 日曆事件詳情
  final CalendarAppointmentDetails details;

  /// 日曆 Bloc
  final CalendarBloc calendarBloc;

  const MaiCalendarAppointmentBuilder({
    super.key,
    this.viewType = CalendarView.month,
    required this.details,
    required this.calendarBloc,
  });

  @override
  State<MaiCalendarAppointmentBuilder> createState() => _MaiCalendarAppointmentBuilderState();
}

class _MaiCalendarAppointmentBuilderState extends State<MaiCalendarAppointmentBuilder> {
  late CalendarBloc _calendarBloc;

  @override
  void initState() {
    super.initState();
    _calendarBloc = widget.calendarBloc;
  }

  @override
  Widget build(BuildContext context) {
    final currentViewType = widget.viewType ?? CalendarView.month;
    switch (currentViewType) {
      case CalendarView.schedule:
        return _buildScheduleView(context, widget.details);
      case CalendarView.day:
        return _buildDayView(context, widget.details);
      case CalendarView.week:
        return _buildWeekView(context, widget.details);
      default:
        return _buildMonthView(context, widget.details);
    }
  }

  /// 月視圖事件呈現
  Widget _buildMonthView(BuildContext context, CalendarAppointmentDetails details) {
    final CalendarEvent event = details.appointments.first as CalendarEvent;
    return GestureDetector(
      onTap: () => _showEventDetails(context, event),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: HexColor(event.color),
          border: Border.all(width: 0.5, color: HexColor(event.color)),
          borderRadius: BorderRadius.circular(3),
        ),
        child: AutoSizeText(
          event.title,
          textAlign: TextAlign.center,
          softWrap: true,
          maxLines: 1,
          minFontSize: 10,
          maxFontSize: 14,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  /// 週視圖事件呈現
  Widget _buildWeekView(BuildContext context, CalendarAppointmentDetails details) {
    final CalendarEvent event = details.appointments.first as CalendarEvent;
    return GestureDetector(
      onTap: () => _showEventDetails(context, event),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: HexColor(event.color),
          border: Border.all(width: 0.5, color: HexColor(event.color)),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: AutoSizeText(
            event.title,
            textAlign: TextAlign.center,
            minFontSize: 10,
            maxFontSize: 14,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  /// 日視圖事件呈現
  Widget _buildDayView(BuildContext context, CalendarAppointmentDetails details) {
    final CalendarEvent event = details.appointments.first as CalendarEvent;
    return GestureDetector(
      onTap: () => _showEventDetails(context, event),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: HexColor(event.color),
          border: Border.all(width: 0.5, color: HexColor(event.color)),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(
          children: [
            if (!event.isAllDay && event.endTime != null)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(event.startTime),
                      style: const TextStyle(fontSize: 10, color: Colors.white70),
                    ),
                    Text(
                      DateFormat('HH:mm').format(event.endTime!),
                      style: const TextStyle(fontSize: 10, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: AutoSizeText(
                  event.title,
                  textAlign: TextAlign.center,
                  minFontSize: 10,
                  maxFontSize: 14,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 行程視圖事件呈現
  Widget _buildScheduleView(BuildContext context, CalendarAppointmentDetails details) {
    final CalendarEvent event = details.appointments.first as CalendarEvent;
    return GestureDetector(
      onTap: () => _showEventDetails(context, event),
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 時間列 - 使用固定寬度確保對齊
            SizedBox(
              width: 90,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 顯示開始時間
                  Text(
                    DateFormat('a hh:mm', 'zh_TW').format(event.startTime),
                    style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  // 無論是否有結束時間，都保持固定高度
                  if (event.endTime != null && !event.isAllDay)
                    Text(
                      DateFormat('a hh:mm', 'zh_TW').format(event.endTime!),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    )
                  else
                    // 即使沒有結束時間，也保留空間確保對齊
                    const SizedBox(height: 12),
                ],
              ),
            ),
            // 垂直線 - 使用固定高度和邊距
            Container(
              width: 4,
              height: 36,
              decoration: BoxDecoration(
                color: HexColor(event.color),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 標題和描述
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (event.locationPath.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          event.locationPath,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 顯示事件詳情
  void _showEventDetails(BuildContext context, CalendarEvent event) {
    MaiCalendarAppointmentDetailView.show(
      context: context,
      event: event,
      calendarBloc: _calendarBloc,
    );
  }
}
