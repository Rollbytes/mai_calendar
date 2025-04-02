import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mai_calendar/src/feature/color_picker/color_picker_bloc.dart';
import 'package:mai_calendar/src/feature/color_picker/color_picker_event.dart';
import 'package:mai_calendar/src/feature/color_picker/color_picker_widget.dart';
import 'package:mai_calendar/src/feature/time_selector/time_selector.dart';
import 'package:mai_calendar/src/feature/time_selector/time_selector_bloc.dart';
import 'package:mai_calendar/src/feature/time_selector/time_selector_event.dart';
import 'package:mai_calendar/src/feature/time_selector/time_selector_state.dart';
import 'package:mai_calendar/src/models/calendar_models.dart' show CalendarEvent;
import 'package:mai_calendar/src/feature/space_selector/space_selector.dart';
import 'package:mai_calendar/src/feature/space_selector/space_selector_bloc.dart';
import 'package:mai_calendar/src/repositories/calendar_repository.dart';
import 'package:mai_calendar/src/models/base_models.dart';
import 'package:mai_calendar/src/models/db_models.dart';
import 'package:mai_calendar/src/calendar_bloc/calendar_bloc.dart';
import 'package:mai_calendar/src/calendar_bloc/calendar_event.dart' as bloc_event;
import 'package:mai_calendar/src/calendar_bloc/calendar_state.dart';

/// 表單模式枚舉
enum MaiCalendarBottomSheetMode {
  /// 創建新事件模式
  create,

  /// 查看/編輯事件模式
  edit,
}

/// 行事曆底部表單 Widget
class MaiCalendarEditor {
  /// 顯示底部表單
  static Future<void> show({
    required BuildContext context,
    required DateTime currentDate,
    required CalendarBloc calendarBloc, // 改為必須參數
    MaiCalendarBottomSheetMode mode = MaiCalendarBottomSheetMode.create,
    CalendarEvent? eventData,
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
              child: _MaiCalendarBottomSheetContent(
                currentDate: currentDate,
                mode: mode,
                eventData: eventData,
                calendarBloc: calendarBloc, // 傳遞 CalendarBloc
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

/// 底部表單內容組件
class _MaiCalendarBottomSheetContent extends StatefulWidget {
  final DateTime currentDate;
  final MaiCalendarBottomSheetMode mode;
  final CalendarEvent? eventData;
  final CalendarBloc calendarBloc;

  const _MaiCalendarBottomSheetContent({
    required this.currentDate,
    this.mode = MaiCalendarBottomSheetMode.create,
    this.eventData,
    required this.calendarBloc,
  });

  @override
  State<_MaiCalendarBottomSheetContent> createState() => _MaiCalendarBottomSheetContentState();
}

class _MaiCalendarBottomSheetContentState extends State<_MaiCalendarBottomSheetContent> {
  late TextEditingController _titleTextEditingController;
  bool _isSpecialTitle = false; // 添加狀態變量來追踪是否有特殊標題
  bool _isSaving = false; // 是否正在保存
  late ColorPickerBloc _colorPickerBloc;

  // 時間選擇相關狀態
  late DateTime _startTime;
  DateTime? _endTime;
  bool _isAllDay = false;
  late TimeSelectorBloc _timeSelectorBloc;

  // 空間選擇相關狀態
  Base? _selectedBase;
  Board? _selectedBoard;
  MaiTable? _selectedTable;
  MaiColumn? _selectedColumn;

  // SpaceSelectorBloc
  late SpaceSelectorBloc _spaceSelectorBloc;

  @override
  void initState() {
    super.initState();
    _titleTextEditingController = TextEditingController();

    // 初始化 Blocs
    _spaceSelectorBloc = SpaceSelectorBloc(repository: CalendarRepository());
    _colorPickerBloc = ColorPickerBloc();

    // 如果有現有事件，初始化顏色
    if (widget.eventData?.color != null) {
      _colorPickerBloc.add(SelectColor(widget.eventData!.color));
    }

    // 確定初始日期
    final initialDate = widget.eventData?.startTime ?? widget.currentDate;

    // 初始化 TimeSelectorBloc，直接使用初始日期
    _timeSelectorBloc = TimeSelectorBloc(initialDate: initialDate);

    if (widget.eventData != null) {
      // 如果是編輯現有事件，使用事件的數據初始化
      _titleTextEditingController.text = widget.eventData!.title;
      _startTime = widget.eventData!.startTime;
      _endTime = widget.eventData!.endTime;
      _isAllDay = widget.eventData!.isAllDay;

      // 初始化選擇的位置信息
      _selectedBase = widget.eventData!.base;
      _selectedBoard = widget.eventData!.board;
      _selectedTable = widget.eventData!.table;
      _selectedColumn = widget.eventData!.column;

      // 更新其他 TimeSelectorBloc 的狀態
      if (_endTime != null) {
        _timeSelectorBloc.add(ToggleEndTime(true));
        _timeSelectorBloc.add(UpdateEndTime(_endTime!));
      }
      _timeSelectorBloc.add(ToggleShowTimeButton(!_isAllDay));
    } else {
      // 新增事件時的初始設定
      _startTime = initialDate;
      _endTime = initialDate.add(const Duration(hours: 1));

      // 設置結束時間
      _timeSelectorBloc.add(ToggleEndTime(true));
      _timeSelectorBloc.add(UpdateEndTime(_endTime!));
    }
  }

  @override
  void dispose() {
    _titleTextEditingController.dispose();
    _spaceSelectorBloc.close(); // 關閉 SpaceSelectorBloc
    _colorPickerBloc.close(); // 關閉 ColorPickerBloc
    _timeSelectorBloc.close(); // 關閉 TimeSelectorBloc
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CalendarBloc, CalendarState>(
      bloc: widget.calendarBloc,
      listener: _handleBlocStateChanges,
      child: _buildContent(context),
    );
  }

  // 處理 Bloc 狀態變化
  void _handleBlocStateChanges(BuildContext context, CalendarState state) {
    if (_isSaving) {
      if (state.status == CalendarStatus.loaded) {
        // 保存成功，關閉表單
        setState(() {
          _isSaving = false;
        });
        Navigator.of(context).pop();
      } else {
        // 其他狀態，重置保存狀態
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // 構建主要內容
  Widget _buildContent(BuildContext context) {
    final draggableController = DraggableScrollableController();
    final screenHeight = MediaQuery.of(context).size.height;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // 當列表達到頂部且繼續向下滑動時，控制整個表單高度
        if (notification is ScrollUpdateNotification && notification.metrics.pixels <= 0 && notification.dragDetails != null) {
          if (draggableController.isAttached) {
            double delta = notification.dragDetails!.delta.dy;
            double newSize = draggableController.size - (delta / screenHeight);
            if (newSize >= 0.5 && newSize <= 0.9) {
              draggableController.animateTo(
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
          if (draggableController.isAttached) {
            // 計算新的尺寸，更平滑的響應
            double delta = details.delta.dy;
            double newSize = draggableController.size - (delta / screenHeight);
            // 限制在允許範圍內
            newSize = newSize.clamp(0.5, 0.9);

            // 使用animateTo而不是jumpTo，但設置非常短的動畫時間
            draggableController.animateTo(
              newSize,
              duration: const Duration(milliseconds: 1),
              curve: Curves.linear,
            );
          }
        },
        // 添加拖動結束處理，實現慣性效果
        onVerticalDragEnd: (details) {
          if (draggableController.isAttached) {
            // 獲取當前尺寸
            final currentSize = draggableController.size;
            // 計算目標尺寸（根據速度和當前位置決定滑動到哪個snap點）
            final double velocity = details.primaryVelocity ?? 0;

            double targetSize;
            if (velocity > 500) {
              // 快速向下滑動
              targetSize = 0.5;
            } else if (velocity < -500) {
              // 快速向上滑動
              targetSize = 0.9;
            } else {
              // 緩慢滑動，根據當前位置決定
              targetSize = currentSize > 0.7 ? 0.9 : 0.5;
            }
            // 平滑過渡到目標尺寸
            draggableController.animateTo(
              targetSize,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
            );
          }
        },
        child: DraggableScrollableSheet(
          controller: draggableController,
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          snap: true,
          snapAnimationDuration: const Duration(milliseconds: 300),
          snapSizes: const [0.5, 0.9],
          builder: (context, scrollController) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 優化表單頂部的拖動指示器
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    child: _buildHeader(context),
                  ),
                  const SizedBox(height: 4),
                  _buildTitleInput(),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: _buildSpecialTitleCheckbox(),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildSpaceSelector(),
                  ),
                  const SizedBox(height: 4),
                  Divider(color: Colors.grey.shade200),
                  Expanded(
                    child: _buildListViewContent(context, scrollController),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: FittedBox(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: const Text(
                  "取消",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildIndicator(),
              const SizedBox(height: 10),
              Text(
                widget.eventData == null ? "新增行程" : "編輯行程",
                style: const TextStyle(fontSize: 16, height: 1),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FittedBox(
              child: TextButton(
                onPressed: _isSaving ? null : _saveEvent, // 避免重複點擊
                style: ButtonStyle(
                  foregroundColor: WidgetStatePropertyAll(_isSaving ? Colors.grey : Theme.of(context).primaryColor),
                ),
                child: _isSaving
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text("儲存", style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildIndicator() {
    return Center(
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

  // 構建創建事件內容
  Widget _buildListViewContent(BuildContext context, ScrollController scrollController) {
    return ListView(
      controller: scrollController, // 使用滾動控制器
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      physics: const AlwaysScrollableScrollPhysics(), // 確保總是可滾動
      children: [
        _buildTimeSelector(),
        const SizedBox(height: 16),
        _buildColorPicker(),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildTitleInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextFormField(
        cursorWidth: 2,
        autofocus: false,
        canRequestFocus: true,
        controller: _titleTextEditingController,
        style: const TextStyle(fontSize: 24),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
          hintText: "行事曆顯示名稱",
          hintStyle: TextStyle(
            fontSize: 24,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialTitleCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _isSpecialTitle,
          onChanged: (value) => setState(() => _isSpecialTitle = value ?? false),
        ),
        Text("需要有特別標題", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(width: 8),
        IconButton(
            icon: Icon(Icons.help_outline, size: 20, color: Theme.of(context).colorScheme.onSecondary),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              // 顯示幫助信息的邏輯，可以稍後實現
              // 例如：showDialog 或 showTooltip
            }),
      ],
    );
  }

  // 構建空間選擇器
  Widget _buildSpaceSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "選擇存放位置",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SpaceSelector(
          isDisabled: widget.mode == MaiCalendarBottomSheetMode.edit,
          eventData: widget.mode == MaiCalendarBottomSheetMode.edit ? widget.eventData : null,
          spaceSelectorBloc: _spaceSelectorBloc, // 使用初始化好的 SpaceSelectorBloc
          onSelectionComplete: (base, board, table, column) {
            setState(() {
              _selectedBase = base;
              _selectedBoard = board;
              _selectedTable = table;
              _selectedColumn = column;
            });
            debugPrint('選擇完成: ${base.name} > ${board.name} > ${table.name} > ${column.name}');
          },
        ),
      ],
    );
  }

  // 保存事件
  void _saveEvent() {
    // 檢查是否已經在保存中
    if (_isSaving) return;

    // 檢查必要信息是否完整
    if (_titleTextEditingController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請輸入行程名稱')),
      );
      return;
    }

    // 檢查是否選擇了存放位置
    if (_selectedBase == null || _selectedBoard == null || _selectedTable == null || _selectedColumn == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請選擇存放位置')),
      );
      return;
    }

    // 設置保存狀態
    setState(() {
      _isSaving = true;
    });

    // 創建或更新事件
    final CalendarEvent newEvent = widget.eventData?.copyWith(
          title: _titleTextEditingController.text,
          color: _colorPickerBloc.state.selectedColor, // 使用 BLoC 狀態獲取顏色
          startTime: _startTime, // 使用選擇的開始時間
          endTime: _endTime, // 使用選擇的結束時間
          isAllDay: _isAllDay, // 使用選擇的全天事件狀態
        ) ??
        CalendarEvent(
          id: DateTime.now().millisecondsSinceEpoch.toString(), // 生成臨時ID
          title: _titleTextEditingController.text,
          startTime: _startTime, // 使用選擇的開始時間
          endTime: _endTime, // 使用選擇的結束時間
          isAllDay: _isAllDay, // 使用選擇的全天事件狀態
          color: _colorPickerBloc.state.selectedColor,
        );

    // 添加空間信息
    final eventWithSpace = newEvent.copyWith(
      baseId: _selectedBase!.id,
      baseName: _selectedBase!.name,
      boardId: _selectedBoard!.id,
      boardName: _selectedBoard!.name,
      tableId: _selectedTable!.id,
      tableName: _selectedTable!.name,
      columnId: _selectedColumn!.id,
      columnName: _selectedColumn!.name,
      base: _selectedBase,
      board: _selectedBoard,
      table: _selectedTable,
      column: _selectedColumn,
    );

    // 使用 CalendarBloc 發送事件
    if (widget.eventData == null) {
      // 創建新事件
      widget.calendarBloc.add(bloc_event.CreateCalendarEvent(eventWithSpace));
    } else {
      // 更新現有事件
      widget.calendarBloc.add(bloc_event.UpdateCalendarEvent(eventWithSpace));
    }

    // 注意：表單關閉由 BlocListener 處理
  }

  // 構建日期時間選擇器
  Widget _buildTimeSelector() {
    return BlocListener<TimeSelectorBloc, TimeSelectorState>(
      bloc: _timeSelectorBloc,
      listener: (context, state) {
        setState(() {
          _startTime = state.selectedStartTime;
          _endTime = state.hasEndTime ? state.selectedEndTime : null;
          _isAllDay = !state.showTimeButton;
        });
      },
      child: TimeSelector(
        timeSelectorBloc: _timeSelectorBloc,
      ),
    );
  }

  Widget _buildColorPicker() {
    return ColorPickerWidget(
      colorPickerBloc: _colorPickerBloc,
      initialColor: widget.eventData?.color, // 只傳遞初始顏色，不再使用本地狀態
      onColorChanged: null, // 不再需要回調更新本地狀態
    );
  }
}
