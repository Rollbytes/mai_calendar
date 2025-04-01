import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'space_selector_bloc.dart';
import 'space_selector_state.dart';
import 'space_selector_event.dart';
import 'package:mai_calendar/src/models/base_models.dart';
import 'package:mai_calendar/src/models/db_models.dart';

/// 空間選擇器底部表單
class SpaceSelectorSheet extends StatefulWidget {
  /// 空間選擇器 Bloc
  final SpaceSelectorBloc spaceSelectorBloc;

  /// 選擇完成後的回調
  final Function(
    Base base,
    Board board,
    MaiTable table,
    MaiColumn column,
  ) onSave;

  const SpaceSelectorSheet({
    super.key,
    required this.spaceSelectorBloc,
    required this.onSave,
  });

  @override
  State<SpaceSelectorSheet> createState() => _SpaceSelectorSheetState();
}

class _SpaceSelectorSheetState extends State<SpaceSelectorSheet> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final SpaceSelectorBloc _spaceSelectorBloc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _spaceSelectorBloc = widget.spaceSelectorBloc;

    _tabController.addListener(() {
      _spaceSelectorBloc.add(UpdateSelectedTab(_tabController.index));
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SpaceSelectorBloc, SpaceSelectorState>(
      bloc: _spaceSelectorBloc,
      listener: (context, state) {
        // 不再自動調用 Navigator.of(context).pop() 關閉表單
        // 只在所有選擇完成時通知狀態更新
        if (state.currentBoard != null && state.currentTable != null && state.currentTimeColumn != null && state.status == SpaceSelectorStatus.loaded) {
          // 只調用回調，確保有一個 Base（即使是默認的）
          final base = state.currentBase ??
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

          widget.onSave(
            base,
            state.currentBoard!,
            state.currentTable!,
            state.currentTimeColumn!,
          );
        }
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildRecentSelectionsTab(),
                  _buildManualSelectionTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 構建頂部
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
          FittedBox(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: const Text(
                "取消",
                style: TextStyle(fontSize: 18, height: 1),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIndicator(),
              const SizedBox(height: 10),
              const Text(
                "選擇空間",
                style: TextStyle(fontSize: 16, height: 1),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FittedBox(
              child: TextButton(
                onPressed: () {
                  // 檢查是否所有選擇都已完成
                  if (_isAllSelectionComplete(_spaceSelectorBloc.state)) {
                    // 關閉表單並調用回調
                    Navigator.of(context).pop();
                    widget.onSave(
                      _spaceSelectorBloc.state.currentBase!,
                      _spaceSelectorBloc.state.currentBoard!,
                      _spaceSelectorBloc.state.currentTable!,
                      _spaceSelectorBloc.state.currentTimeColumn!,
                    );
                  } else {
                    // 顯示錯誤提示
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('請完成所有選擇')),
                    );
                  }
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                ),
                child: const Text(
                  "儲存",
                  style: TextStyle(fontSize: 18, height: 1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 構建指示器
  Widget _buildIndicator() {
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

  /// 構建選項卡欄
  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: Theme.of(context).primaryColor,
      unselectedLabelColor: Colors.grey,
      tabs: const [
        Tab(text: '最近選擇'),
        Tab(text: '選擇空間'),
      ],
    );
  }

  /// 構建最近選擇選項卡內容
  Widget _buildRecentSelectionsTab() {
    return BlocBuilder<SpaceSelectorBloc, SpaceSelectorState>(
      bloc: _spaceSelectorBloc,
      builder: (context, state) {
        if (state.status == SpaceSelectorStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == SpaceSelectorStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.error ?? '載入失敗'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _tabController.animateTo(1),
                  child: const Text('手動選擇空間'),
                ),
              ],
            ),
          );
        }

        if (state.recentSelections.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('尚無最近選擇記錄'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _tabController.animateTo(1),
                  child: const Text('手動選擇空間'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.recentSelections.length,
          itemBuilder: (context, index) {
            final selection = state.recentSelections[index];
            return ListTile(
              title: Text('${selection.boardId} > ${selection.tableId} > ${selection.columnId}'),
              subtitle: Text('上次使用: ${selection.updatedAt.toString().split('.')[0]}'),
              onTap: () {
                _spaceSelectorBloc.add(SelectRecentSelection(selection));
              },
              selected: state.currentSelection == selection,
            );
          },
        );
      },
    );
  }

  /// 構建手動選擇選項卡內容
  Widget _buildManualSelectionTab() {
    return BlocBuilder<SpaceSelectorBloc, SpaceSelectorState>(
      bloc: _spaceSelectorBloc,
      builder: (context, state) {
        if (state.status == SpaceSelectorStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 直接顯示協作版選擇下拉菜單
              _buildBoardDropdown(state),
              const SizedBox(height: 16),

              // 表格選擇下拉菜單 (如果有協作版)
              if (state.currentBoard != null) _buildTableDropdown(state),
              if (state.currentBoard != null) const SizedBox(height: 16),

              // 欄位選擇下拉菜單 (如果有表格)
              if (state.currentTable != null) _buildColumnDropdown(state),
              if (state.currentTable != null) const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  /// 構建協作版下拉選擇
  Widget _buildBoardDropdown(SpaceSelectorState state) {
    // 確保 currentBoard 在 boards 列表中
    final Board? selectedBoard = state.currentBoard;
    String? selectedBoardId;

    if (selectedBoard != null && state.boards.isNotEmpty) {
      // 檢查當前選擇的 board 是否在列表中
      final boardInList = state.boards.any((board) => board.id == selectedBoard.id);
      if (boardInList) {
        selectedBoardId = selectedBoard.id;
      }
    }

    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: '選擇協作版',
        border: OutlineInputBorder(),
      ),
      value: selectedBoardId,
      items: state.boards.map((board) {
        return DropdownMenuItem<String>(
          value: board.id,
          child: Text(board.name),
        );
      }).toList(),
      onChanged: (boardId) {
        if (boardId != null) {
          // 查找選擇的 board
          final board = state.boards.firstWhere(
            (b) => b.id == boardId,
            orElse: () => state.boards.isNotEmpty
                ? state.boards.first
                : Board(
                    id: "default_board",
                    name: "默認協作版",
                    description: "",
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                    createdBy: "system",
                    members: [],
                    roles: [],
                  ),
          );
          _spaceSelectorBloc.add(SelectBoard(board));
        }
      },
    );
  }

  /// 構建表格下拉選擇
  Widget _buildTableDropdown(SpaceSelectorState state) {
    // 確保 currentTable 在 tables 列表中
    final MaiTable? selectedTable = state.currentTable;
    String? selectedTableId;

    if (selectedTable != null && state.tables.isNotEmpty) {
      // 檢查當前選擇的 table 是否在列表中
      final tableInList = state.tables.any((table) => table.id == selectedTable.id);
      if (tableInList) {
        selectedTableId = selectedTable.id;
      }
    }

    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: '選擇表格',
        border: OutlineInputBorder(),
      ),
      value: selectedTableId,
      items: state.tables.map((table) {
        return DropdownMenuItem<String>(
          value: table.id,
          child: Text(table.name),
        );
      }).toList(),
      onChanged: (tableId) {
        if (tableId != null) {
          // 查找選擇的 table
          final table = state.tables.firstWhere(
            (t) => t.id == tableId,
            orElse: () => state.tables.isNotEmpty
                ? state.tables.first
                : MaiTable(
                    id: "default_table",
                    name: "默認表格",
                    description: "",
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                    columns: [],
                    rows: [],
                    layouts: [],
                    permissions: {},
                  ),
          );
          _spaceSelectorBloc.add(SelectTable(table));
        }
      },
    );
  }

  /// 構建欄位下拉選擇
  Widget _buildColumnDropdown(SpaceSelectorState state) {
    // 確保 currentTimeColumn 在 timeColumns 列表中
    final MaiColumn? selectedColumn = state.currentTimeColumn;
    String? selectedColumnId;

    if (selectedColumn != null && state.timeColumns.isNotEmpty) {
      // 檢查當前選擇的 column 是否在列表中
      final columnInList = state.timeColumns.any((column) => column.id == selectedColumn.id);
      if (columnInList) {
        selectedColumnId = selectedColumn.id;
      }
    }

    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: '選擇欄位',
        border: OutlineInputBorder(),
      ),
      value: selectedColumnId,
      items: state.timeColumns.map((column) {
        return DropdownMenuItem<String>(
          value: column.id,
          child: Text(column.name),
        );
      }).toList(),
      onChanged: (columnId) {
        if (columnId != null) {
          // 查找選擇的 column
          final column = state.timeColumns.firstWhere(
            (c) => c.id == columnId,
            orElse: () => state.timeColumns.isNotEmpty
                ? state.timeColumns.first
                : MaiColumn(
                    id: "default_column",
                    name: "默認欄位",
                    type: ColumnType.datetime,
                    options: {},
                  ),
          );
          _spaceSelectorBloc.add(SelectTimeColumn(column));
        }
      },
    );
  }

  /// 檢查是否所有選擇都已完成
  bool _isAllSelectionComplete(SpaceSelectorState state) {
    return state.currentBoard != null && state.currentTable != null && state.currentTimeColumn != null;
  }
}
