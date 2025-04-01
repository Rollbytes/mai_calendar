import 'package:flutter/material.dart';
import 'base_models.dart';
import 'db_models.dart';

/// MaiCell 代表表格中的資料格
class MaiCell {
  final String id; // 單元格唯一識別符
  final String rowId; // 所屬資料列ID
  final String columnId; // 所屬欄位ID
  dynamic value; // 單元格值
  final DateTime updatedAt; // 最後更新時間
  final String updatedBy; // 最後更新者ID

  MaiCell({
    required this.id,
    required this.rowId,
    required this.columnId,
    required this.value,
    required this.updatedAt,
    required this.updatedBy,
  });

  factory MaiCell.fromJson(Map<String, dynamic> json) {
    return MaiCell(
      id: json['id'],
      rowId: json['rowId'],
      columnId: json['columnId'],
      value: json['value'],
      updatedAt: DateTime.parse(json['updatedAt']),
      updatedBy: json['updatedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rowId': rowId,
      'columnId': columnId,
      'value': value,
      'updatedAt': updatedAt.toIso8601String(),
      'updatedBy': updatedBy,
    };
  }
}

/// 日期時間值類別，用於儲存DateTime欄位的值
class DateTimeValue {
  final String title; // 事件標題
  final DateTime startTime; // 開始時間
  final DateTime? endTime; // 結束時間 (可選)
  final bool includeTime; // 是否包含時間
  final bool hasEndTime; // 是否有結束時間
  final String color; // 顏色 (#RRGGBBAA)
  final String timeZone; // 時區

  DateTimeValue({
    required this.title,
    required this.startTime,
    this.endTime,
    this.includeTime = true,
    this.hasEndTime = false,
    this.color = "#FF4081FF", // 默認顏色為粉色
    this.timeZone = "UTC+8",
  });

  factory DateTimeValue.fromJson(Map<String, dynamic> json) {
    return DateTimeValue(
      title: json['title'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      includeTime: json['includeTime'] ?? true,
      hasEndTime: json['hasEndTime'] ?? false,
      color: json['color'] ?? "#FF4081FF",
      timeZone: json['timeZone'] ?? "UTC+8",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'includeTime': includeTime,
      'hasEndTime': hasEndTime,
      'color': color,
      'timeZone': timeZone,
    };
  }

  Color get colorValue {
    // 從RRGGBBAA格式解析顏色
    try {
      final hex = color.replaceAll("#", "");
      if (hex.length == 8) {
        return Color(int.parse('0x${hex.substring(6, 8)}${hex.substring(0, 6)}'));
      } else {
        return const Color(0xFFFF4081); // 默認顏色
      }
    } catch (e) {
      return const Color(0xFFFF4081); // 錯誤時的默認顏色
    }
  }
}

/// CalendarEvent 表示一個行事曆事件
class CalendarEvent {
  final String id; // 事件ID
  final String title; // 事件標題
  final DateTime startTime; // 開始時間
  final DateTime? endTime; // 結束時間
  final bool isAllDay; // 是否為全天事件
  final String color; // 顏色
  final String notes; // 事件描述
  final String locationPath; // 地點路徑

  // 原有的資料來源識別符
  final String? rowId; // 如果事件來自MaiTable，對應的rowId
  final String? columnId; // 如果事件來自MaiTable，對應的columnId

  // 階層結構資訊
  final String? baseId; // Base ID
  final String? baseName; // Base 名稱
  final String? boardId; // Board ID
  final String? boardName; // Board 名稱
  final String? tableId; // MaiTable ID
  final String? tableName; // MaiTable 名稱
  final String? columnName; // MaiColumn 名稱
  final Map<String, dynamic>? columnOptions; // MaiColumn 的設定選項

  // 關聯的實體對象
  final Base? base; // 對應的 Base 實體
  final Board? board; // 對應的 Board 實體
  final MaiTable? table; // 對應的 MaiTable 實體
  final MaiColumn? column; // 對應的 MaiColumn 實體
  final MaiRow? row; // 對應的 MaiRow 實體

  CalendarEvent({
    required this.id,
    required this.title,
    required this.startTime,
    this.endTime,
    this.isAllDay = false,
    this.color = "#FF4081FF",
    this.notes = "",
    this.locationPath = "",
    this.rowId,
    this.columnId,
    // 階層結構資訊
    this.baseId,
    this.baseName,
    this.boardId,
    this.boardName,
    this.tableId,
    this.tableName,
    this.columnName,
    this.columnOptions,
    // 關聯實體
    this.base,
    this.board,
    this.table,
    this.column,
    this.row,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'],
      title: json['title'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      isAllDay: json['isAllDay'] ?? false,
      color: json['color'] ?? "#FF4081FF",
      notes: json['notes'] ?? "",
      locationPath: json['locationPath'] ?? "",
      rowId: json['rowId'],
      columnId: json['columnId'],
      // 階層結構資訊
      baseId: json['baseId'],
      baseName: json['baseName'],
      boardId: json['boardId'],
      boardName: json['boardName'],
      tableId: json['tableId'],
      tableName: json['tableName'],
      columnName: json['columnName'],
      columnOptions: json['columnOptions'],
      // 關聯實體在外部設置
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'isAllDay': isAllDay,
      'color': color,
      'notes': notes,
      'locationPath': locationPath,
      'rowId': rowId,
      'columnId': columnId,
      // 階層結構資訊
      'baseId': baseId,
      'baseName': baseName,
      'boardId': boardId,
      'boardName': boardName,
      'tableId': tableId,
      'tableName': tableName,
      'columnName': columnName,
      'columnOptions': columnOptions,
      // 關聯實體不序列化
    };
  }

  /// 從MaiCell創建CalendarEvent
  factory CalendarEvent.fromMaiCell(
    MaiCell cell,
    String rowTitle, {
    String? baseId,
    String? baseName,
    String? boardId,
    String? boardName,
    String? tableId,
    String? tableName,
    String? columnName,
    Map<String, dynamic>? columnOptions,
    Base? base,
    Board? board,
    MaiTable? table,
    MaiColumn? column,
    MaiRow? row,
  }) {
    if (cell.value is! Map<String, dynamic>) {
      throw Exception('Invalid cell value format');
    }

    final dateTimeValue = DateTimeValue.fromJson(cell.value);

    return CalendarEvent(
      id: cell.id,
      title: dateTimeValue.title.isNotEmpty ? dateTimeValue.title : rowTitle,
      startTime: dateTimeValue.startTime,
      endTime: dateTimeValue.endTime,
      isAllDay: !dateTimeValue.includeTime,
      color: dateTimeValue.color,
      notes: "",
      locationPath: "",
      rowId: cell.rowId,
      columnId: cell.columnId,
      // 階層結構資訊
      baseId: baseId,
      baseName: baseName,
      boardId: boardId,
      boardName: boardName,
      tableId: tableId,
      tableName: tableName,
      columnName: columnName,
      columnOptions: columnOptions,
      // 關聯實體
      base: base,
      board: board,
      table: table,
      column: column,
      row: row,
    );
  }


  /// 創建帶有更新的欄位的事件副本
  CalendarEvent copyWith({
    String? id,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    bool? isAllDay,
    String? color,
    String? notes,
    String? locationPath,
    String? source,
    String? rowId,
    String? columnId,
    String? baseId,
    String? baseName,
    String? boardId,
    String? boardName,
    String? tableId,
    String? tableName,
    String? columnName,
    Map<String, dynamic>? columnOptions,
    Base? base,
    Board? board,
    MaiTable? table,
    MaiColumn? column,
    MaiRow? row,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAllDay: isAllDay ?? this.isAllDay,
      color: color ?? this.color,
      notes: notes ?? this.notes,
      locationPath: locationPath ?? this.locationPath,
      rowId: rowId ?? this.rowId,
      columnId: columnId ?? this.columnId,
      baseId: baseId ?? this.baseId,
      baseName: baseName ?? this.baseName,
      boardId: boardId ?? this.boardId,
      boardName: boardName ?? this.boardName,
      tableId: tableId ?? this.tableId,
      tableName: tableName ?? this.tableName,
      columnName: columnName ?? this.columnName,
      columnOptions: columnOptions ?? this.columnOptions,
      base: base ?? this.base,
      board: board ?? this.board,
      table: table ?? this.table,
      column: column ?? this.column,
      row: row ?? this.row,
    );
  }
}
