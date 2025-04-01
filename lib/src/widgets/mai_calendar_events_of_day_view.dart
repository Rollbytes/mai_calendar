import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mai_calendar/src/calendar_bloc/calendar_bloc.dart';
import 'package:mai_calendar/src/calendar_bloc/calendar_state.dart';
import 'package:mai_calendar/src/feature/color_picker/hex_color_adapter.dart';
import 'package:mai_calendar/src/models/calendar_models.dart';
import 'mai_calendar_editor.dart';

/// 行事曆日期事件列表
/// 用於顯示某一天的所有行程
class MaiCalendarEventsOfDayView {
  /// 顯示行事曆日期事件列表
  static Future<void> show({
    required BuildContext context,
    required DateTime selectedDate,
    required CalendarBloc calendarBloc,
    Widget? floatingActionButton,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black54,
        pageBuilder: (_, __, ___) {
          return Material(
            type: MaterialType.transparency,
            child: SafeArea(
              bottom: false,
              child: _MaiCalendarEventsOfDayViewContent(
                selectedDate: selectedDate,
                calendarBloc: calendarBloc,
                floatingActionButton: floatingActionButton,
              ),
            ),
          );
        },
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1), // 從底部滑入
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
      ),
    );
  }
}

/// 行事曆日期事件列表內容組件
class _MaiCalendarEventsOfDayViewContent extends StatefulWidget {
  /// 選中的日期
  final DateTime selectedDate;

  /// 行事曆 Bloc
  final CalendarBloc calendarBloc;

  /// 創建按鈕
  final Widget? floatingActionButton;

  const _MaiCalendarEventsOfDayViewContent({
    required this.selectedDate,
    required this.calendarBloc,
    this.floatingActionButton,
  });

  @override
  State<_MaiCalendarEventsOfDayViewContent> createState() => _MaiCalendarEventsOfDayViewContentState();
}

class _MaiCalendarEventsOfDayViewContentState extends State<_MaiCalendarEventsOfDayViewContent> {
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildDraggableSheet(context),
        if (widget.floatingActionButton != null)
          Positioned(
            bottom: 100,
            right: 20,
            child: widget.floatingActionButton!,
          ),
      ],
    );
  }

  Widget _buildDraggableSheet(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // 當列表達到頂部且繼續向下滑動時，控制整個表單高度
        if (notification is ScrollUpdateNotification && notification.metrics.pixels <= 0 && notification.dragDetails != null) {
          if (_sheetController.isAttached) {
            double delta = notification.dragDetails!.delta.dy;
            double newSize = _sheetController.size - (delta / screenHeight);
            if (newSize >= 0.45 && newSize <= 0.95) {
              _sheetController.animateTo(
                newSize,
                duration: const Duration(milliseconds: 1),
                curve: Curves.linear,
              );
              return true; // 攔截滾動事件
            }
          }
        }
        return false; // 不攔截其他滾動事件
      },
      child: GestureDetector(
        // 使用更敏感的拖動檢測
        onVerticalDragUpdate: (details) {
          if (_sheetController.isAttached) {
            // 計算新的尺寸，更平滑的響應
            double delta = details.delta.dy;
            double newSize = _sheetController.size - (delta / screenHeight);
            // 限制在允許範圍內
            newSize = newSize.clamp(0.45, 0.95);

            // 使用animateTo而不是jumpTo，但設置非常短的動畫時間
            _sheetController.animateTo(
              newSize,
              duration: const Duration(milliseconds: 1),
              curve: Curves.linear,
            );
          }
        },
        // 添加拖動結束處理，實現慣性效果
        onVerticalDragEnd: (details) {
          if (_sheetController.isAttached) {
            // 獲取當前尺寸
            final currentSize = _sheetController.size;
            // 計算目標尺寸（根據速度和當前位置決定滑動到哪個snap點）
            final double velocity = details.primaryVelocity ?? 0;

            double targetSize;
            if (velocity > 500) {
              // 快速向下滑動
              targetSize = 0.45;
            } else if (velocity < -500) {
              // 快速向上滑動
              targetSize = 0.95;
            } else {
              // 緩慢滑動，根據當前位置決定
              targetSize = currentSize > 0.7 ? 0.95 : 0.45;
            }

            // 如果目標尺寸是最小值且用戶正在快速向下滑動，關閉視圖
            if (targetSize == 0.45 && velocity > 800) {
              Navigator.of(context).pop();
              return;
            }

            // 平滑過渡到目標尺寸
            _sheetController.animateTo(
              targetSize,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
            );
          }
        },
        child: DraggableScrollableSheet(
          controller: _sheetController,
          initialChildSize: 0.45,
          minChildSize: 0.45,
          maxChildSize: 0.95,
          snap: true,
          snapAnimationDuration: const Duration(milliseconds: 300),
          snapSizes: const [0.45, 0.95],
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.grey, spreadRadius: 2, blurRadius: 4)],
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildDragIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 6,
        width: 40,
        decoration: const ShapeDecoration(
          color: Colors.black12,
          shape: StadiumBorder(),
        ),
      ),
    );
  }

  Widget _buildDateHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatDate(widget.selectedDate),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
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
      bloc: widget.calendarBloc,
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
                color: HexColor(event.color),
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
      calendarBloc: widget.calendarBloc,
    );
  }
}
