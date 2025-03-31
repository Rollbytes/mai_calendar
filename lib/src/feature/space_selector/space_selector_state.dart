import 'package:equatable/equatable.dart';
import 'package:mai_calendar/src/models/base_models.dart';
import 'package:mai_calendar/src/models/db_models.dart';

/// 空間選擇器狀態
enum SpaceSelectorStatus {
  /// 初始狀態
  initial,

  /// 載入中
  loading,

  /// 載入完成
  loaded,

  /// 錯誤
  error,
}

/// 空間選擇器狀態數據
class SpaceSelectorState extends Equatable {
  /// 所有基地列表
  final List<Base> bases;

  /// 所有協作版列表
  final List<Board> boards;

  /// 所有表格列表
  final List<MaiTable> tables;

  /// 所有時間欄位列表
  final List<MaiColumn> timeColumns;

  /// 先前選擇的欄位數據
  final List<ColumnSelection> recentSelections;

  /// 狀態
  final SpaceSelectorStatus status;

  /// 錯誤信息
  final String? error;

  /// 當前選擇的基地
  final Base? currentBase;

  /// 當前選擇的協作版
  final Board? currentBoard;

  /// 當前選擇的表格
  final MaiTable? currentTable;

  /// 當前選擇的時間欄位
  final MaiColumn? currentTimeColumn;

  /// 當前選擇的記錄
  final ColumnSelection? currentSelection;

  /// 當前選項卡索引
  final int currentTabIndex;

  /// 是否禁用選擇器
  final bool isDisabled;

  const SpaceSelectorState(
      {this.status = SpaceSelectorStatus.initial,
      this.bases = const [],
      this.boards = const [],
      this.tables = const [],
      this.timeColumns = const [],
      this.recentSelections = const [],
      this.error,
      this.currentBoard,
      this.currentTable,
      this.currentTimeColumn,
      this.currentTabIndex = 0,
      this.currentSelection,
      this.currentBase,
      this.isDisabled = false});

  /// 創建初始狀態
  factory SpaceSelectorState.initial() {
    return const SpaceSelectorState(
      status: SpaceSelectorStatus.initial,
      boards: [],
      tables: [],
      timeColumns: [],
      recentSelections: [],
      currentBoard: null,
      currentTable: null,
      currentTimeColumn: null,
      currentTabIndex: 0,
      currentSelection: null,
      bases: [],
      currentBase: null,
      isDisabled: false,
    );
  }

  /// 創建新的狀態實例
  SpaceSelectorState copyWith({
    SpaceSelectorStatus? status,
    List<Board>? boards,
    List<MaiTable>? tables,
    List<MaiColumn>? timeColumns,
    List<ColumnSelection>? recentSelections,
    String? error,
    Board? currentBoard,
    MaiTable? currentTable,
    MaiColumn? currentTimeColumn,
    int? currentTabIndex,
    ColumnSelection? currentSelection,
    List<Base>? bases,
    Base? currentBase,
    bool? isDisabled,
  }) {
    return SpaceSelectorState(
      boards: boards ?? this.boards,
      tables: tables ?? this.tables,
      timeColumns: timeColumns ?? this.timeColumns,
      status: status ?? this.status,
      error: error ?? this.error,
      currentBase: currentBase ?? this.currentBase,
      currentBoard: currentBoard ?? this.currentBoard,
      currentTable: currentTable ?? this.currentTable,
      currentTimeColumn: currentTimeColumn ?? this.currentTimeColumn,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      recentSelections: recentSelections ?? this.recentSelections,
      currentSelection: currentSelection ?? this.currentSelection,
      bases: bases ?? this.bases,
      isDisabled: isDisabled ?? this.isDisabled,
    );
  }

  @override
  List<Object?> get props => [
        boards,
        tables,
        timeColumns,
        recentSelections,
        status,
        error,
        currentBoard,
        currentTable,
        currentTimeColumn,
        currentTabIndex,
        currentSelection,
        bases,
        currentBase,
        isDisabled,
      ];
}

/// 欄位選擇記錄
class ColumnSelection extends Equatable {
  /// 基地ID
  final String baseId;

  /// 協作版ID
  final String boardId;

  /// 表格ID
  final String tableId;

  /// 欄位ID
  final String columnId;

  /// 更新時間
  final DateTime updatedAt;

  const ColumnSelection({
    required this.baseId,
    required this.boardId,
    required this.tableId,
    required this.columnId,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [baseId, boardId, tableId, columnId, updatedAt];
}
