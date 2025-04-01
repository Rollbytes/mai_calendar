import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../calendar_bloc/calendar_bloc.dart';
import '../models/calendar_models.dart';
import '../feature/color_picker/hex_color_adapter.dart';
import 'mai_calendar_editor.dart';

/// 行事曆行程詳情查看視圖
class MaiCalendarAppointmentDetailView {
  /// 顯示行程詳細資訊
  static Future<void> show({
    required BuildContext context,
    required CalendarEvent event,
    required CalendarBloc calendarBloc,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MaiCalendarAppointmentDetailContent(
        event: event,
        calendarBloc: calendarBloc,
      ),
    );
  }
}

/// 行程詳情內容組件
class MaiCalendarAppointmentDetailContent extends StatefulWidget {
  /// 行程事件
  final CalendarEvent event;

  /// 行事曆 Bloc
  final CalendarBloc calendarBloc;

  const MaiCalendarAppointmentDetailContent({
    super.key,
    required this.event,
    required this.calendarBloc,
  });

  @override
  State<MaiCalendarAppointmentDetailContent> createState() => _MaiCalendarAppointmentDetailContentState();
}

class _MaiCalendarAppointmentDetailContentState extends State<MaiCalendarAppointmentDetailContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopBar(context),
          Divider(height: 0.5, color: Theme.of(context).colorScheme.onSecondary),
          const SizedBox(height: 20),
          _buildTitleWithColor(widget.event),
          const SizedBox(height: 16),
          _buildSpaceInfoSection(widget.event),
          const SizedBox(height: 16),
          _buildDateTimeSection(widget.event),
          const SizedBox(height: 8),
          Divider(height: 0.5, color: Colors.grey),
          _buildLocationSection(widget.event),
          const SizedBox(height: 16),
          const Text('相關資訊', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildTabBar(context),
          const SizedBox(height: 16),
          _buildTabBarView(),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        Expanded(
          child: Column(
            children: [
              _buildIndicator(),
              const SizedBox(height: 4),
              const Text(
                "行程詳情",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
            MaiCalendarEditor.show(
              context: context,
              currentDate: widget.event.startTime,
              mode: MaiCalendarBottomSheetMode.edit,
              eventData: widget.event,
              calendarBloc: widget.calendarBloc,
            );
          },
        ),
      ],
    );
  }

  Widget _buildTitleWithColor(CalendarEvent event) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: HexColor(event.color),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            event.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSpaceInfoSection(CalendarEvent event) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // 基地
          _buildBaseItem(text: event.baseName ?? '未指定'),
          _buildDivider(symbol: "-"),
          // 看板
          _buildClickableItem(
            icon: Icons.grid_3x3_outlined,
            text: event.boardName ?? '未指定',
            onTap: () {
              // TODO: 處理看板點擊事件
            },
          ),
          _buildDivider(),
          // 表格
          _buildClickableItem(
            icon: Icons.table_chart_outlined,
            text: event.tableName ?? '未指定',
            onTap: () {
              // TODO: 處理表格點擊事件
            },
          ),
          _buildDivider(),
          // 欄位
          _buildClickableItem(
            icon: Icons.view_column_outlined,
            text: event.columnName ?? '未指定',
            onTap: () {
              // TODO: 處理欄位點擊事件
            },
          ),
        ],
      ),
    );
  }

  // 基地項目（不可點擊）
  Widget _buildBaseItem({required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // 可點擊項目（用於看板、表格、欄位）
  Widget _buildClickableItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.grey[600],
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 分隔符
  Widget _buildDivider({String? symbol}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        symbol ?? "/",
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildDateTimeSection(CalendarEvent event) {
    final startTime = event.startTime.toLocal();
    final endTime = event.endTime?.toLocal();

    if (event.isAllDay) {
      // 全天行程顯示格式
      return Row(
        mainAxisAlignment: endTime != null ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: endTime != null ? CrossAxisAlignment.center : CrossAxisAlignment.start,
              children: [
                Text(
                  '${startTime.year}年',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  '${startTime.month}月${startTime.day}日 週${_getWeekDay(startTime)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            child: Text(
              '全天',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          if (endTime != null && !isSameDay(startTime, endTime)) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Icon(
                Icons.arrow_forward_ios,
                size: 24,
              ),
            ),
            Text(
              '${endTime.month}月${endTime.day}日 週${_getWeekDay(endTime)}',
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
          ],
        ],
      );
    } else {
      // 一般行程顯示格式
      return Row(
        mainAxisAlignment: endTime != null ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${startTime.year}年${startTime.month}月${startTime.day}日 週${_getWeekDay(startTime)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTime(startTime),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (endTime != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Icon(
                Icons.arrow_forward_ios,
                size: 24,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${endTime.year}年${endTime.month}月${endTime.day}日 週${_getWeekDay(endTime)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(endTime),
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ],
        ],
      );
    }
  }

  Widget _buildLocationSection(CalendarEvent event) {
    if (event.locationPath.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on_outlined, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              event.locationPath,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.onSecondary),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.blue[600],
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        indicator: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.blueAccent),
        ),
        padding: EdgeInsets.zero,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(
            height: 32,
            child: Text('欄位'),
          ),
          Tab(
            height: 32,
            child: Text('留言'),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: const Center(child: Text('欄位表格開發中', style: TextStyle(color: Colors.grey))),
            ),
          ),
          // 留言 - 暫時用placeholder表示
          const Center(child: Text('留言開發中', style: TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }

  Widget _buildIndicator() {
    return Container(
      height: 6,
      width: 40,
      decoration: const ShapeDecoration(
        color: Colors.black12,
        shape: StadiumBorder(),
      ),
    );
  }

  // 格式化時間
  String _formatTime(DateTime time) {
    return DateFormat('h:mm a', 'en_US').format(time).toUpperCase();
  }

  // 取得星期幾
  String _getWeekDay(DateTime date) {
    const weekDays = ['日', '一', '二', '三', '四', '五', '六'];
    return weekDays[date.weekday % 7];
  }

  // 判斷是否為同一天
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }
}
