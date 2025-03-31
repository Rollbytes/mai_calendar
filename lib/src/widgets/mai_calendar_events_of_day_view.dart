import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mai_calendar/src/calendar_bloc/calendar_bloc.dart';
import 'package:mai_calendar/src/calendar_bloc/calendar_state.dart';
import 'package:mai_calendar/src/models/calendar_models.dart';
import 'mai_calendar_editor.dart';

/// 行事曆日期事件列表
/// 用於顯示某一天的所有行程
class MaiCalendarEventsOfDayView extends StatefulWidget {
  /// 選中的日期
  final DateTime selectedDate;

  /// 行事曆 Bloc
  final CalendarBloc calendarBloc;

  /// 創建按鈕
  final Widget? floatingActionButton;

  const MaiCalendarEventsOfDayView({
    super.key,
    required this.selectedDate,
    required this.calendarBloc,
    this.floatingActionButton,
  });

  @override
  State<MaiCalendarEventsOfDayView> createState() => _MaiCalendarEventsOfDayViewState();
}

class _MaiCalendarEventsOfDayViewState extends State<MaiCalendarEventsOfDayView> {
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  final ScrollController _scrollController = ScrollController();
  late CalendarBloc _calendarBloc;
  bool _isScrollAnimating = false;

  @override
  void initState() {
    super.initState();
    _calendarBloc = widget.calendarBloc;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          _buildDraggableSheet(context),
          if (widget.floatingActionButton != null)
            Positioned(
              bottom: 100,
              right: 20,
              child: widget.floatingActionButton!,
            ),
        ],
      ),
    );
  }

  Widget _buildDraggableSheet(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      snap: true,
      snapSizes: const [0.45, 0.95],
      controller: _sheetController,
      builder: (context, scrollController) {
        return NotificationListener<ScrollNotification>(
          onNotification: _handleScrollNotification,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey, spreadRadius: 2, blurRadius: 4)],
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Column(
              children: [
                _buildDragIndicator(),
                _buildDateHeader(),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildEventList(scrollController),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification && !_isScrollAnimating) {
      if (notification.metrics.pixels < 0 && notification.dragDetails != null) {
        if (_sheetController.isAttached) {
          final currentSize = _sheetController.size;
          if (currentSize >= 0.8) {
            _isScrollAnimating = true;
            _sheetController
                .animateTo(
              0.45,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
            )
                .whenComplete(() {
              _isScrollAnimating = false;
            });
          } else if (currentSize <= 0.5) {
            Navigator.of(context).pop();
          }
        }
      }
    }
    return true;
  }

  Widget _buildDragIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        width: 36,
        height: 4,
      ),
    );
  }

  Widget _buildDateHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatDate(widget.selectedDate),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            "${widget.selectedDate.day}日",
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('M月d日 EEEE', 'zh_TW').format(date);
  }

  Widget _buildEventList(ScrollController scrollController) {
    return BlocBuilder<CalendarBloc, CalendarState>(
      bloc: _calendarBloc,
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final eventsOfDay = _getEventsOfDay(state.events);

        if (eventsOfDay.isEmpty) {
          return const Center(
            child: Text('今天沒有行程', style: TextStyle(fontSize: 16, color: Colors.grey)),
          );
        }

        return ListView.separated(
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: eventsOfDay.length,
          itemBuilder: (context, index) => _buildEventItem(eventsOfDay[index]),
        );
      },
    );
  }

  List<CalendarEvent> _getEventsOfDay(List<CalendarEvent> allEvents) {
    final startOfDay = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
    );
    final endOfDay = DateTime(widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day, 23, 59, 59, 999);

    return allEvents.where((event) {
      if (event.endTime == null) {
        return event.startTime.isAfter(startOfDay.subtract(const Duration(milliseconds: 1))) &&
            event.startTime.isBefore(endOfDay.add(const Duration(milliseconds: 1)));
      }

      return event.startTime.isBefore(endOfDay) && event.endTime!.isAfter(startOfDay.subtract(const Duration(milliseconds: 1)));
    }).toList();
  }

  Widget _buildEventItem(CalendarEvent event) {
    return InkWell(
      onTap: () => _showEventDetails(event),
      child: SizedBox(
        height: 40,
        child: Row(
          children: [
            const SizedBox(width: 4),
            _buildTimeDisplay(event.startTime, event.endTime),
            const SizedBox(width: 4),
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: _parseColor(event.color),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hexColor) {
    try {
      if (hexColor.startsWith('#')) {
        String colorStr = hexColor.substring(1);
        if (colorStr.length == 6) {
          colorStr = 'FF$colorStr'; // 添加不透明度
        } else if (colorStr.length == 8) {
          // 已經有不透明度，不需要處理
        }
        return Color(int.parse(colorStr, radix: 16));
      }
      return Colors.blue; // 默認顏色
    } catch (e) {
      return Colors.blue; // 發生錯誤時返回默認顏色
    }
  }

  Widget _buildTimeDisplay(DateTime startTime, DateTime? endTime) {
    // 格式化時間顯示
    if (endTime == null) {
      final formattedTime = _formatSingleTime(startTime);
      return Container(
        alignment: Alignment.center,
        width: 60,
        child: Text(
          formattedTime,
          style: const TextStyle(fontSize: 10.0, color: Colors.black),
          textAlign: TextAlign.start,
        ),
      );
    }

    // 如果有結束時間，則顯示兩行
    final formattedStartTime = _formatSingleTime(startTime);
    final formattedEndTime = _formatSingleTime(endTime);

    return Container(
      alignment: Alignment.center,
      width: 60,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              formattedStartTime,
              style: const TextStyle(fontSize: 10.0, color: Colors.black),
              textAlign: TextAlign.start,
            ),
          ),
          Expanded(
            child: Text(
              formattedEndTime,
              style: const TextStyle(fontSize: 10.0, color: Colors.grey),
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }

  String _formatSingleTime(DateTime time) {
    return DateFormat('ahh:mm', 'zh_TW').format(time);
  }

  void _showEventDetails(CalendarEvent event) {
    MaiCalendarEditor.show(
      context: context,
      currentDate: widget.selectedDate,
      mode: MaiCalendarBottomSheetMode.edit,
      eventData: event,
      calendarBloc: _calendarBloc,
    );
  }
}
