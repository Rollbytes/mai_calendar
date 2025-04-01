import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mai_calendar/src/models/base_models.dart';
import 'package:mai_calendar/src/models/db_models.dart' hide MaiCell;
import 'package:mai_calendar/src/repositories/calendar_repository.dart';

import 'space_selector_event.dart';
import 'space_selector_state.dart';

/// 空間選擇器 Bloc
class SpaceSelectorBloc extends Bloc<SpaceSelectorEvent, SpaceSelectorState> {
  // 使用 CalendarRepository 替代原本的多個存儲庫
  final CalendarRepository _repository;

  // 歷史選擇記錄
  final List<ColumnSelection> _selections = [];

  SpaceSelectorBloc({
    required CalendarRepository repository,
  })  : _repository = repository,
        super(SpaceSelectorState.initial()) {
    // 基本事件處理
    on<UpdateSelectedTab>(_onUpdateSelectedTab);
    on<SelectBase>(_onSelectBase);
    on<SelectBoard>(_onSelectBoard);
    on<SelectTable>(_onSelectTable);
    on<SelectTimeColumn>(_onSelectTimeColumn);
    on<SelectRecentSelection>(_onSelectRecentSelection);

    // 保存和創建事件
    on<SaveColumnSelection>(_onSaveColumnSelection);
    on<CreateDateTimeColumn>(_onCreateDateTimeColumn);
    on<CreateTable>(_onCreateTable);

    // 數據加載事件
    on<GetCellSpaceInfo>(_onGetCellSpaceInfo);
    on<GetRecentSelections>(_onGetRecentSelections);
    on<GetFirstSelectionInfo>(_onGetFirstSelectionInfo);
    on<UpdateRecentSelections>(_onUpdateRecentSelections);
    on<LoadBoards>(_onLoadBoards);

    // 初始化時加載數據
    add(LoadBoards());
  }

  // 更新選擇的選項卡
  Future<void> _onUpdateSelectedTab(UpdateSelectedTab event, Emitter<SpaceSelectorState> emit) async {
    emit(state.copyWith(currentTabIndex: event.index));

    switch (event.index) {
      case 0: // 歷史選擇選項卡
        if (state.recentSelections.isNotEmpty) {
          add(GetFirstSelectionInfo());
        }
        break;
      case 1: // 基地選項卡
        add(LoadBoards());
        break;
    }
  }

  // 選擇基地
  Future<void> _onSelectBase(SelectBase event, Emitter<SpaceSelectorState> emit) async {
    emit(state.copyWith(
      currentBase: event.base,
      status: SpaceSelectorStatus.loading,
    ));

    try {
      // 從 repository 獲取基地下的協作版
      final boards = await _getBoards(baseId: event.base.id);

      emit(state.copyWith(
        boards: boards,
        status: SpaceSelectorStatus.loaded,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SpaceSelectorStatus.error,
        error: "載入協作版失敗: $e",
      ));
    }
  }

  // 選擇協作版
  Future<void> _onSelectBoard(SelectBoard event, Emitter<SpaceSelectorState> emit) async {
    emit(state.copyWith(
      currentBoard: event.board,
      status: SpaceSelectorStatus.loading,
    ));

    try {
      // 嘗試從 repository 獲取協作版對應的基地
      final base = await _repository.getBaseForBoard(event.board.id);

      // 如果沒有找到對應的基地，則創建一個默認的基地
      final defaultBase = base ??
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

      // 從 repository 獲取協作版下的表格
      final tables = await _getTables(boardId: event.board.id);

      emit(state.copyWith(
        tables: tables,
        currentBase: defaultBase, // 設置基地
        status: SpaceSelectorStatus.loaded,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SpaceSelectorStatus.error,
        error: "載入表格失敗: $e",
      ));
    }
  }

  // 選擇表格
  Future<void> _onSelectTable(SelectTable event, Emitter<SpaceSelectorState> emit) async {
    emit(state.copyWith(
      currentTable: event.table,
      status: SpaceSelectorStatus.loading,
    ));

    try {
      // 從 repository 獲取表格下的日期時間欄位
      final columns = await _getDateTimeColumns(tableId: event.table.id);

      emit(state.copyWith(
        timeColumns: columns,
        status: SpaceSelectorStatus.loaded,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SpaceSelectorStatus.error,
        error: "載入欄位失敗: $e",
      ));
    }
  }

  // 選擇時間欄位
  Future<void> _onSelectTimeColumn(SelectTimeColumn event, Emitter<SpaceSelectorState> emit) async {
    emit(state.copyWith(
      currentTimeColumn: event.column,
      status: SpaceSelectorStatus.loaded,
    ));

    // 如果所有必要的選擇都已完成，則保存選擇記錄
    if (state.currentBase != null && state.currentBoard != null && state.currentTable != null) {
      add(SaveColumnSelection(
        base: state.currentBase!,
        board: state.currentBoard!,
        table: state.currentTable!,
        column: event.column,
      ));
    }
  }

  // 選擇最近使用的欄位
  Future<void> _onSelectRecentSelection(SelectRecentSelection event, Emitter<SpaceSelectorState> emit) async {
    emit(state.copyWith(
      status: SpaceSelectorStatus.loading,
      currentSelection: event.selection,
    ));

    try {
      // 獲取選擇記錄對應的實體
      final base = await _getBase(event.selection.baseId);
      final board = await _getBoard(event.selection.boardId);
      final table = await _getTable(event.selection.tableId);
      final column = await _getColumn(event.selection.columnId);

      // 嘗試從 repository 獲取協作版對應的基地
      Base? baseFromBoard = await _repository.getBaseForBoard(board.id);

      // 使用從 board 獲取的 base 或者原始的 base
      final finalBase = baseFromBoard ?? base;

      emit(state.copyWith(
        currentBase: finalBase,
        currentBoard: board,
        currentTable: table,
        currentTimeColumn: column,
        status: SpaceSelectorStatus.loaded,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SpaceSelectorStatus.error,
        error: "載入選擇記錄失敗: $e",
      ));
    }
  }

  // 保存欄位選擇記錄
  Future<void> _onSaveColumnSelection(SaveColumnSelection event, Emitter<SpaceSelectorState> emit) async {
    final selection = ColumnSelection(
      baseId: event.base.id,
      boardId: event.board.id,
      tableId: event.table.id,
      columnId: event.column.id,
      updatedAt: DateTime.now(),
    );

    // 保存選擇記錄到本地
    _saveSelectionToLocal(selection);

    emit(state.copyWith(
      currentSelection: selection,
      status: SpaceSelectorStatus.loaded,
    ));
  }

  // 創建日期時間欄位
  Future<void> _onCreateDateTimeColumn(CreateDateTimeColumn event, Emitter<SpaceSelectorState> emit) async {
    emit(state.copyWith(status: SpaceSelectorStatus.loading));

    try {
      // 使用 CalendarRepository 創建新欄位 (未實現，這裡使用模擬數據)
      final newColumn = MaiColumn(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: event.columnName,
        type: ColumnType.datetime,
        options: {},
      );

      // 更新欄位列表
      final columns = [...state.timeColumns, newColumn];

      emit(state.copyWith(
        timeColumns: columns,
        currentTimeColumn: newColumn,
        status: SpaceSelectorStatus.loaded,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SpaceSelectorStatus.error,
        error: "創建欄位失敗: $e",
      ));
    }
  }

  // 創建表格
  Future<void> _onCreateTable(CreateTable event, Emitter<SpaceSelectorState> emit) async {
    emit(state.copyWith(status: SpaceSelectorStatus.loading));

    try {
      // 使用 CalendarRepository 創建新表格 (未實現，這裡使用模擬數據)
      final newTable = MaiTable(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: event.tableName,
        description: "",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        columns: [],
        rows: [],
        layouts: [],
        permissions: {},
      );

      // 更新表格列表
      final tables = [...state.tables, newTable];

      emit(state.copyWith(
        tables: tables,
        currentTable: newTable,
        status: SpaceSelectorStatus.loaded,
      ));

      // 自動創建時間欄位
      add(CreateDateTimeColumn(
        board: event.board,
        table: newTable,
        columnName: "日期時間",
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SpaceSelectorStatus.error,
        error: "創建表格失敗: $e",
      ));
    }
  }

  // 根據單元格獲取空間信息
  Future<void> _onGetCellSpaceInfo(GetCellSpaceInfo event, Emitter<SpaceSelectorState> emit) async {
    emit(state.copyWith(status: SpaceSelectorStatus.loading));

    try {
      // 獲取單元格所在的表格信息
      final cell = event.cell;

      // 獲取相關信息
      final column = await _getColumn(cell.columnId);
      final table = await _getTable("table1"); // 假設我們知道 tableId
      final board = await _getBoard("board1"); // 假設我們知道 boardId
      final base = await _getBase("base1"); // 假設我們知道 baseId

      emit(state.copyWith(
        currentBase: base,
        currentBoard: board,
        currentTable: table,
        currentTimeColumn: column,
        status: SpaceSelectorStatus.loaded,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SpaceSelectorStatus.error,
        error: "獲取空間信息失敗: $e",
      ));
    }
  }

  // 獲取最近選擇的欄位
  Future<void> _onGetRecentSelections(GetRecentSelections event, Emitter<SpaceSelectorState> emit) async {
    emit(state.copyWith(status: SpaceSelectorStatus.loading));

    // 獲取最近的選擇記錄
    final selections = await _getRecentSelectionsFromLocal();

    if (selections.isNotEmpty) {
      emit(state.copyWith(
        recentSelections: selections,
        status: SpaceSelectorStatus.loaded,
      ));

      // 加載第一個選擇
      add(GetFirstSelectionInfo());
    } else {
      emit(state.copyWith(
        status: SpaceSelectorStatus.error,
        error: "尚無存取空間記錄",
      ));
    }
  }

  // 獲取第一個選擇的信息
  Future<void> _onGetFirstSelectionInfo(GetFirstSelectionInfo event, Emitter<SpaceSelectorState> emit) async {
    if (state.recentSelections.isNotEmpty) {
      // 選擇第一個記錄
      add(SelectRecentSelection(state.recentSelections.first));
    }
  }

  // 更新最近選擇記錄
  Future<void> _onUpdateRecentSelections(UpdateRecentSelections event, Emitter<SpaceSelectorState> emit) async {
    // 獲取最新的選擇記錄
    final selections = await _getRecentSelectionsFromLocal();

    emit(state.copyWith(
      recentSelections: selections,
      currentSelection: event.selection,
      status: SpaceSelectorStatus.loaded,
    ));
  }

  // 加載所有協作版
  Future<void> _onLoadBoards(LoadBoards event, Emitter<SpaceSelectorState> emit) async {
    emit(state.copyWith(status: SpaceSelectorStatus.loading));

    try {
      // 獲取所有基地和協作版
      final bases = await _getBases();
      final boards = await _getAllBoards();

      emit(state.copyWith(
        bases: bases,
        boards: boards,
        status: SpaceSelectorStatus.loaded,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SpaceSelectorStatus.error,
        error: "載入數據失敗: $e",
      ));
    }
  }

  // 以下是私有方法，用於從 CalendarRepository 獲取數據

  // 獲取所有基地
  Future<List<Base>> _getBases() async {
    // 註：這裡應該從 repository 獲取數據，目前使用模擬數據
    // TODO: 從真實的 API 獲取基地數據
    return [
      Base(
        id: "base1",
        name: "研發部",
        description: "研發部門的工作空間",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        ownerId: "user1",
        roles: [],
        members: [],
        contents: [],
      ),
      Base(
        id: "base2",
        name: "行銷部",
        description: "行銷部門的工作空間",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        ownerId: "user1",
        roles: [],
        members: [],
        contents: [],
      ),
      Base(
        id: "base3",
        name: "個人空間",
        description: "我的個人工作空間",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        ownerId: "user1",
        roles: [],
        members: [],
        contents: [],
      ),
    ];
  }

  // 獲取特定基地
  Future<Base> _getBase(String id) async {
    try {
      final base = await _repository.getBase(id);
      if (base != null) {
        return base;
      }
    } catch (e) {
      // 忽略錯誤，使用默認基地
    }

    // 如果通過 repository 獲取失敗，則返回默認基地
    return Base(
      id: id,
      name: "默認基地",
      description: "自動生成的基地",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      ownerId: "system",
      roles: const [],
      members: const [],
      contents: const [],
    );
  }

  // 獲取所有協作版
  Future<List<Board>> _getAllBoards() async {
    try {
      // 從 repository 獲取 board 到 base 映射關係
      final Map<String, String> boardToBaseMap = await _repository.getBoardBaseMap();

      if (boardToBaseMap.isNotEmpty) {
        List<Board> allBoards = [];

        // 從 repository 獲取每個 board
        for (String boardId in boardToBaseMap.keys) {
          try {
            final board = await _repository.getBoard(boardId);
            if (board != null) {
              allBoards.add(board);
            }
          } catch (e) {
            // 忽略獲取單個 board 時的錯誤
          }
        }

        if (allBoards.isNotEmpty) {
          return allBoards;
        }
      }
    } catch (e) {
      // 忽略錯誤，使用默認數據
    }

    // 如果通過 repository 獲取失敗，則返回模擬數據
    final bases = await _getBases();
    List<Board> allBoards = [];

    for (var base in bases) {
      final boards = await _getBoards(baseId: base.id);
      allBoards.addAll(boards);
    }

    return allBoards;
  }

  // 獲取指定基地下的協作版
  Future<List<Board>> _getBoards({required String baseId}) async {
    // 註：這裡應該從 repository 獲取數據，目前使用模擬數據
    // TODO: 從真實的 API 獲取協作版數據
    return [
      Board(
        id: "${baseId}_board1",
        name: "專案管理",
        description: "專案進度追蹤",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: "user1",
        members: [],
        roles: [],
      ),
      Board(
        id: "${baseId}_board2",
        name: "會議記錄",
        description: "團隊會議紀要",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: "user1",
        members: [],
        roles: [],
      ),
    ];
  }

  // 獲取特定協作版
  Future<Board> _getBoard(String id) async {
    try {
      final board = await _repository.getBoard(id);
      if (board != null) {
        return board;
      }
    } catch (e) {
      // 忽略錯誤，使用默認協作版
    }

    // 如果通過 repository 獲取失敗，則返回默認協作版
    return Board(
      id: id,
      name: "協作版 $id",
      description: "自動生成的協作版",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: "system",
      members: [],
      roles: [],
    );
  }

  // 獲取指定協作版下的表格
  Future<List<MaiTable>> _getTables({required String boardId}) async {
    // 創建模擬數據
    return [
      MaiTable(
        id: "${boardId}_table1",
        name: "任務清單",
        description: "專案任務追蹤",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        columns: [],
        rows: [],
        layouts: [],
        permissions: {},
      ),
      MaiTable(
        id: "${boardId}_table2",
        name: "行事曆",
        description: "團隊排程",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        columns: [],
        rows: [],
        layouts: [],
        permissions: {},
      ),
    ];
  }

  // 獲取特定表格
  Future<MaiTable> _getTable(String id) async {
    // 查找符合 id 的表格
    final boardId = id.split('_').first;
    final tables = await _getTables(boardId: boardId);
    return tables.firstWhere((table) => table.id == id,
        orElse: () => MaiTable(
              id: id,
              name: "表格 $id",
              description: "",
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              columns: [],
              rows: [],
              layouts: [],
              permissions: {},
            ));
  }

  // 獲取特定表格下的日期時間欄位
  Future<List<MaiColumn>> _getDateTimeColumns({required String tableId}) async {
    // 創建模擬數據
    return [
      MaiColumn(
        id: "${tableId}_column1",
        name: "開始日期",
        type: ColumnType.datetime,
        options: {},
      ),
      MaiColumn(
        id: "${tableId}_column2",
        name: "截止日期",
        type: ColumnType.datetime,
        options: {},
      ),
      MaiColumn(
        id: "${tableId}_column3",
        name: "活動時間",
        type: ColumnType.datetime,
        options: {},
      ),
    ];
  }

  // 獲取特定欄位
  Future<MaiColumn> _getColumn(String id) async {
    // 對於簡化，我們返回一個新創建的列
    return MaiColumn(
      id: id,
      name: "欄位 $id",
      type: ColumnType.datetime,
      options: {},
    );
  }

  // 從本地獲取選擇記錄
  Future<List<ColumnSelection>> _getRecentSelectionsFromLocal() async {
    // 模擬數據
    return _selections;
  }

  // 保存選擇記錄到本地
  void _saveSelectionToLocal(ColumnSelection selection) {
    // 檢查是否已存在同樣位置的記錄
    _selections.removeWhere(
        (s) => s.baseId == selection.baseId && s.boardId == selection.boardId && s.tableId == selection.tableId && s.columnId == selection.columnId);

    // 添加新記錄
    _selections.add(selection);

    // 按時間排序
    _selections.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    // 限制保存的記錄數量
    if (_selections.length > 10) {
      _selections.removeLast();
    }
  }
}
