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
        if (state.currentBase != null &&
            state.currentBoard != null &&
            state.currentTable != null &&
            state.currentTimeColumn != null &&
            state.status == SpaceSelectorStatus.loaded) {
          // 只調用回調，不自動關閉表單
          widget.onSave(
            state.currentBase!,
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
              // 基地選擇下拉菜單
              _buildBaseDropdown(state),
              const SizedBox(height: 16),

              // 協作版選擇下拉菜單 (如果有基地)
              if (state.currentBase != null) _buildBoardDropdown(state),
              if (state.currentBase != null) const SizedBox(height: 16),

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

  /// 構建基地下拉選擇
  Widget _buildBaseDropdown(SpaceSelectorState state) {
    return DropdownButtonFormField<Base>(
      decoration: const InputDecoration(
        labelText: '選擇基地',
        border: OutlineInputBorder(),
      ),
      value: state.currentBase,
      items: state.bases.map((base) {
        return DropdownMenuItem<Base>(
          value: base,
          child: Text(base.name),
        );
      }).toList(),
      onChanged: (base) {
        if (base != null) {
          _spaceSelectorBloc.add(SelectBase(base));
        }
      },
    );
  }

  /// 構建協作版下拉選擇
  Widget _buildBoardDropdown(SpaceSelectorState state) {
    return DropdownButtonFormField<Board>(
      decoration: const InputDecoration(
        labelText: '選擇協作版',
        border: OutlineInputBorder(),
      ),
      value: state.currentBoard,
      items: state.boards.map((board) {
        return DropdownMenuItem<Board>(
          value: board,
          child: Text(board.name),
        );
      }).toList(),
      onChanged: (board) {
        if (board != null) {
          _spaceSelectorBloc.add(SelectBoard(board));
        }
      },
    );
  }

  /// 構建表格下拉選擇
  Widget _buildTableDropdown(SpaceSelectorState state) {
    return DropdownButtonFormField<MaiTable>(
      decoration: const InputDecoration(
        labelText: '選擇表格',
        border: OutlineInputBorder(),
      ),
      value: state.currentTable,
      items: state.tables.map((table) {
        return DropdownMenuItem<MaiTable>(
          value: table,
          child: Text(table.name),
        );
      }).toList(),
      onChanged: (table) {
        if (table != null) {
          _spaceSelectorBloc.add(SelectTable(table));
        }
      },
    );
  }

  /// 構建欄位下拉選擇
  Widget _buildColumnDropdown(SpaceSelectorState state) {
    return DropdownButtonFormField<MaiColumn>(
      decoration: const InputDecoration(
        labelText: '選擇欄位',
        border: OutlineInputBorder(),
      ),
      value: state.currentTimeColumn,
      items: state.timeColumns.map((column) {
        return DropdownMenuItem<MaiColumn>(
          value: column,
          child: Text(column.name),
        );
      }).toList(),
      onChanged: (column) {
        if (column != null) {
          _spaceSelectorBloc.add(SelectTimeColumn(column));
        }
      },
    );
  }

  /// 檢查是否所有選擇都已完成
  bool _isAllSelectionComplete(SpaceSelectorState state) {
    return state.currentBase != null && state.currentBoard != null && state.currentTable != null && state.currentTimeColumn != null;
  }
}
