import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../src/calendar_bloc/calendar_bloc.dart';
import '../src/calendar_bloc/calendar_event.dart';
import '../src/calendar_bloc/calendar_state.dart';
import '../src/repositories/calendar_repository.dart';
import '../src/widgets/mai_calendar_widget.dart';

/// 行事曆示例頁面
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late CalendarRepository _repository;
  late CalendarBloc _calendarBloc;

  @override
  void initState() {
    super.initState();
    // 初始化依賴
    _repository = CalendarRepository();
    _calendarBloc = CalendarBloc(repository: _repository);

    // 載入初始事件
    _calendarBloc.add(const LoadCalendarEvents());
  }

  @override
  void dispose() {
    _calendarBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _calendarBloc,
      child: SafeArea(
        child: BlocBuilder<CalendarBloc, CalendarState>(
          builder: (context, state) {
            return Column(
              children: [
                // 頂部操作區域
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '行事曆',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          // 視圖切換按鈕
                          PopupMenuButton<CalendarView>(
                            tooltip: '切換視圖',
                            icon: const Icon(Icons.view_day),
                            onSelected: (CalendarView view) {
                              _calendarBloc.add(ChangeCalendarView(view));
                            },
                            itemBuilder: (BuildContext context) => <PopupMenuEntry<CalendarView>>[
                              const PopupMenuItem<CalendarView>(
                                value: CalendarView.day,
                                child: Text('日視圖'),
                              ),
                              const PopupMenuItem<CalendarView>(
                                value: CalendarView.week,
                                child: Text('週視圖'),
                              ),
                              const PopupMenuItem<CalendarView>(
                                value: CalendarView.month,
                                child: Text('月視圖'),
                              ),
                              const PopupMenuItem<CalendarView>(
                                value: CalendarView.schedule,
                                child: Text('列表視圖'),
                              ),
                            ],
                          ),
                          // 添加事件按鈕
                          IconButton(
                            icon: const Icon(Icons.add),
                            tooltip: '添加事件',
                            onPressed: _addNewEvent,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 日曆部分
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      children: [
                        MaiCalendarWidget(
                          calendarBloc: _calendarBloc,
                          initialView: state.currentView,
                          allowViewNavigation: false,
                          onEventTap: (event) {
                            // 可以在這裡添加事件點擊處理邏輯
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('點擊事件: ${event.title}')),
                            );
                          },
                        ),
                        // 加載指示器
                        if (state.isLoading && state.events.isEmpty)
                          const Center(
                            child: CircularProgressIndicator(),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 添加新事件的對話框
  void _addNewEvent() {
    final titleController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedStartTime = TimeOfDay.now();
    TimeOfDay? selectedEndTime;
    bool isAllDay = false;
    String? selectedColor;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('新增事件'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: '事件標題',
                        hintText: '請輸入事件標題',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('日期'),
                      subtitle: Text(
                        '${selectedDate.year}/${selectedDate.month}/${selectedDate.day}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('全天事件'),
                      value: isAllDay,
                      onChanged: (value) {
                        setState(() {
                          isAllDay = value ?? false;
                        });
                      },
                    ),
                    if (!isAllDay) ...[
                      ListTile(
                        title: const Text('開始時間'),
                        subtitle: Text(
                          '${selectedStartTime.hour}:${selectedStartTime.minute.toString().padLeft(2, '0')}',
                        ),
                        trailing: const Icon(Icons.access_time),
                        onTap: () async {
                          final pickedTime = await showTimePicker(
                            context: context,
                            initialTime: selectedStartTime,
                          );
                          if (pickedTime != null) {
                            setState(() {
                              selectedStartTime = pickedTime;
                            });
                          }
                        },
                      ),
                      ListTile(
                        title: const Text('結束時間 (可選)'),
                        subtitle: Text(
                          selectedEndTime != null ? '${selectedEndTime!.hour}:${selectedEndTime!.minute.toString().padLeft(2, '0')}' : '未設定',
                        ),
                        trailing: const Icon(Icons.access_time),
                        onTap: () async {
                          final pickedTime = await showTimePicker(
                            context: context,
                            initialTime: selectedEndTime ?? selectedStartTime.replacing(hour: selectedStartTime.hour + 1),
                          );
                          if (pickedTime != null) {
                            setState(() {
                              selectedEndTime = pickedTime;
                            });
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // 獲取所需數據
                    final title = titleController.text.trim();
                    if (title.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('請輸入事件標題')),
                      );
                      return;
                    }

                    // 創建開始和結束時間
                    final startTime = isAllDay
                        ? DateTime(selectedDate.year, selectedDate.month, selectedDate.day)
                        : DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            selectedStartTime.hour,
                            selectedStartTime.minute,
                          );

                    DateTime? endTime;
                    if (!isAllDay && selectedEndTime != null) {
                      endTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedEndTime!.hour,
                        selectedEndTime!.minute,
                      );
                      // 如果結束時間早於開始時間，調整為第二天
                      if (endTime.isBefore(startTime)) {
                        endTime = endTime.add(const Duration(days: 1));
                      }
                    }

                    // 提交事件創建
                    _calendarBloc.add(
                      CreateSimpleCalendarEvent(
                        title: title,
                        startTime: startTime,
                        endTime: endTime,
                        isAllDay: isAllDay,
                        color: selectedColor ?? '#000000',
                      ),
                    );

                    Navigator.of(context).pop();
                  },
                  child: const Text('保存'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
