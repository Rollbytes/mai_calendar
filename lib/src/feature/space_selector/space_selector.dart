import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mai_calendar/src/models/base_models.dart';
import 'package:mai_calendar/src/models/db_models.dart';
import 'package:mai_calendar/src/models/calendar_models.dart';
import 'space_selector_bloc.dart';
import 'space_selector_event.dart';
import 'space_selector_state.dart';
import 'space_selector_sheet.dart';

/// 空間選擇器元件
///
/// 用於選擇 CalendarEvent 要存放的位置（Base、Board、Table、Column）
class SpaceSelector extends StatefulWidget {
  final SpaceSelectorBloc spaceSelectorBloc;
  final bool isDisabled;

  /// 當前編輯的事件，編輯模式下用於顯示現有事件的位置資訊
  final CalendarEvent? eventData;

  /// 當選擇完成時的回調
  final Function(Base base, Board board, MaiTable table, MaiColumn column)? onSelectionComplete;

  const SpaceSelector({
    super.key,
    required this.spaceSelectorBloc,
    this.isDisabled = false,
    this.eventData,
    this.onSelectionComplete,
  });

  @override
  State<SpaceSelector> createState() => _SpaceSelectorState();
}

class _SpaceSelectorState extends State<SpaceSelector> {
  late final SpaceSelectorBloc _spaceSelectorBloc;
  Base? _selectedBase;
  Board? _selectedBoard;
  MaiTable? _selectedTable;
  MaiColumn? _selectedTimeColumn;

  @override
  void initState() {
    super.initState();
    // 使用提供的 Bloc
    _spaceSelectorBloc = widget.spaceSelectorBloc;

    // 如果有現有事件數據，則使用事件數據中的位置信息
    if (widget.eventData != null) {
      _setEventLocation();
    } else {
      // 初始加載數據
      _spaceSelectorBloc.add(GetRecentSelections());
    }
  }

  /// 設置事件位置信息
  void _setEventLocation() {
    final event = widget.eventData;
    if (event == null) return;

    setState(() {
      // 設置選中的基地、協作版、表格和欄位
      _selectedBase = event.base;
      _selectedBoard = event.board;
      _selectedTable = event.table;
      _selectedTimeColumn = event.column;
    });

    // 向 bloc 發送事件以更新選中狀態
    if (_selectedBase != null) {
      _spaceSelectorBloc.add(SelectBase(_selectedBase!));
    }
    if (_selectedBoard != null) {
      _spaceSelectorBloc.add(SelectBoard(_selectedBoard!));
    }
    if (_selectedTable != null) {
      _spaceSelectorBloc.add(SelectTable(_selectedTable!));
    }
    if (_selectedTimeColumn != null) {
      _spaceSelectorBloc.add(SelectTimeColumn(_selectedTimeColumn!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SpaceSelectorBloc, SpaceSelectorState>(
      bloc: _spaceSelectorBloc,
      listener: (context, state) {
        setState(() {
          _selectedBase = state.currentBase;
          _selectedBoard = state.currentBoard;
          _selectedTable = state.currentTable;
          _selectedTimeColumn = state.currentTimeColumn;
        });

        // 如果所有選擇都完成，調用回調函數
        if (_selectedBoard != null && _selectedTable != null && _selectedTimeColumn != null && widget.onSelectionComplete != null) {
          // 確保有一個有效的 Base
          final base = _selectedBase ??
              Base(
                id: "default_base",
                name: "默認基地",
                description: "自動關聯的基地",
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                ownerId: "system",
                roles: const [],
                members: const [],
                contents: const [],
              );

          widget.onSelectionComplete!(base, _selectedBoard!, _selectedTable!, _selectedTimeColumn!);
        }
      },
      child: BlocBuilder<SpaceSelectorBloc, SpaceSelectorState>(
        bloc: _spaceSelectorBloc,
        builder: (context, state) {
          return _buildSpaceSelectorWidget(
            context: context,
            state: state,
            spaceSelectorBloc: _spaceSelectorBloc,
          );
        },
      ),
    );
  }

  Widget _buildSpaceSelectorWidget({
    required BuildContext context,
    required SpaceSelectorState state,
    required SpaceSelectorBloc spaceSelectorBloc,
  }) {
    final bool isDisabled = widget.isDisabled || state.isDisabled;

    return InkWell(
      onTap: isDisabled ? null : () => _showSelector(context: context, state: state, spaceSelectorBloc: spaceSelectorBloc),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey.shade200 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 協作版選擇
              _PathItem(
                icon: Icons.dashboard_outlined,
                text: _selectedBoard?.name ?? widget.eventData?.boardName ?? "選擇協作版",
                isDisabled: isDisabled,
              ),
              _buildSeparator(),

              // 表格選擇
              _PathItem(
                icon: Icons.table_chart_outlined,
                text: _selectedTable?.name ?? widget.eventData?.tableName ?? "選擇表格",
                isDisabled: isDisabled,
              ),
              _buildSeparator(),

              // 欄位選擇
              _PathItem(
                icon: Icons.view_column_outlined,
                text: _selectedTimeColumn?.name ?? widget.eventData?.columnName ?? "選擇欄位",
                isDisabled: isDisabled,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeparator() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Icon(Icons.chevron_right, size: 20, color: Colors.grey),
    );
  }

  void _showSelector({
    required BuildContext context,
    required SpaceSelectorState state,
    required SpaceSelectorBloc spaceSelectorBloc,
  }) {
    showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => SpaceSelectorSheet(
        spaceSelectorBloc: spaceSelectorBloc,
        onSave: (base, board, table, column) {
          // 確保類型安全
          final Base safeBase = base;
          final Board safeBoard = board;
          final MaiTable safeTable = table;
          final MaiColumn safeColumn = column;

          setState(() {
            _selectedBase = safeBase;
            _selectedBoard = safeBoard;
            _selectedTable = safeTable;
            _selectedTimeColumn = safeColumn;
          });

          // 保存選擇並通知回調
          if (widget.onSelectionComplete != null) {
            widget.onSelectionComplete!(safeBase, safeBoard, safeTable, safeColumn);
          }
        },
      ),
    );
  }
}

/// 路徑項目元件
class _PathItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDisabled;

  const _PathItem({
    required this.icon,
    required this.text,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: isDisabled ? Colors.grey.shade400 : null),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDisabled ? Colors.grey.shade400 : null,
          ),
        ),
      ],
    );
  }
}
