// Events
import 'package:mai_calendar/src/models/base_models.dart';
import 'package:mai_calendar/src/models/db_models.dart' hide MaiCell;
import 'package:mai_calendar/src/models/calendar_models.dart';
import 'space_selector_state.dart';

/// 空間選擇器事件基類
abstract class SpaceSelectorEvent {}

/// 更新當前選項卡
class UpdateSelectedTab extends SpaceSelectorEvent {
  final int index;
  UpdateSelectedTab(this.index);
}

/// 選擇基地
class SelectBase extends SpaceSelectorEvent {
  final Base base;
  SelectBase(this.base);
}

/// 選擇協作版
class SelectBoard extends SpaceSelectorEvent {
  final Board board;
  SelectBoard(this.board);
}

/// 選擇表格
class SelectTable extends SpaceSelectorEvent {
  final MaiTable table;
  SelectTable(this.table);
}

/// 選擇時間欄位
class SelectTimeColumn extends SpaceSelectorEvent {
  final MaiColumn column;
  SelectTimeColumn(this.column);
}

/// 選擇最近使用的欄位
class SelectRecentSelection extends SpaceSelectorEvent {
  final ColumnSelection selection;
  SelectRecentSelection(this.selection);
}

/// 保存欄位選擇
class SaveColumnSelection extends SpaceSelectorEvent {
  final Base base;
  final Board board;
  final MaiTable table;
  final MaiColumn column;

  SaveColumnSelection({required this.base, required this.board, required this.table, required this.column});
}

/// 創建日期時間欄位
class CreateDateTimeColumn extends SpaceSelectorEvent {
  final Board board;
  final MaiTable table;
  final String columnName;

  CreateDateTimeColumn({required this.board, required this.table, required this.columnName});
}

/// 創建表格
class CreateTable extends SpaceSelectorEvent {
  final Board board;
  final String tableName;
  final String color;

  CreateTable({required this.board, required this.tableName, required this.color});
}

/// 根據單元格獲取空間信息
class GetCellSpaceInfo extends SpaceSelectorEvent {
  final MaiCell cell;
  GetCellSpaceInfo(this.cell);
}

/// 獲取最近選擇的欄位
class GetRecentSelections extends SpaceSelectorEvent {}

/// 獲取第一個最近選擇的欄位信息
class GetFirstSelectionInfo extends SpaceSelectorEvent {}

/// 更新最近選擇的欄位
class UpdateRecentSelections extends SpaceSelectorEvent {
  final ColumnSelection selection;
  UpdateRecentSelections({required this.selection});
}

/// 加載協作版
class LoadBoards extends SpaceSelectorEvent {}
