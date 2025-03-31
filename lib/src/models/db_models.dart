/// MaiDB 是版內的資料庫系統
class MaiDB {
  final String id; // 資料庫唯一識別符
  final String boardId; // 所屬協作版ID
  final String name; // 資料庫名稱
  final String description; // 資料庫描述
  final DateTime createdAt; // 創建時間
  final DateTime updatedAt; // 最後更新時間
  final String createdBy; // 創建者ID
  final List<MaiTable> tables; // 資料庫中的所有表格
  final Map<String, bool> permissions; // 資料庫特定權限

  MaiDB({
    required this.id,
    required this.boardId,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.tables,
    required this.permissions,
  });

  factory MaiDB.fromJson(Map<String, dynamic> json) {
    return MaiDB(
      id: json['id'],
      boardId: json['boardId'],
      name: json['name'],
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      createdBy: json['createdBy'],
      tables: (json['tables'] as List<dynamic>?)?.map((e) => MaiTable.fromJson(e)).toList() ?? [],
      permissions: Map<String, bool>.from(json['permissions'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'boardId': boardId,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'tables': tables.map((e) => e.toJson()).toList(),
      'permissions': permissions,
    };
  }
}

/// MaiTable 代表一個資料表
class MaiTable {
  final String id; // 表格唯一識別符
  final String name; // 表格名稱
  final String description; // 表格描述
  final DateTime createdAt; // 創建時間
  final DateTime updatedAt; // 最後更新時間
  final List<MaiColumn> columns; // 表格中的所有欄位
  final List<MaiRow> rows; // 表格中的所有資料列
  final List<MaiTableLayout> layouts; // 表格視圖佈局
  final Map<String, bool> permissions; // 表格特定權限

  MaiTable({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.columns,
    required this.rows,
    required this.layouts,
    required this.permissions,
  });

  factory MaiTable.fromJson(Map<String, dynamic> json) {
    return MaiTable(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      columns: (json['columns'] as List<dynamic>?)?.map((e) => MaiColumn.fromJson(e)).toList() ?? [],
      rows: (json['rows'] as List<dynamic>?)?.map((e) => MaiRow.fromJson(e)).toList() ?? [],
      layouts: (json['layouts'] as List<dynamic>?)?.map((e) => MaiTableLayout.fromJson(e)).toList() ?? [],
      permissions: Map<String, bool>.from(json['permissions'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'columns': columns.map((e) => e.toJson()).toList(),
      'rows': rows.map((e) => e.toJson()).toList(),
      'layouts': layouts.map((e) => e.toJson()).toList(),
      'permissions': permissions,
    };
  }
}

/// MaiColumn 代表表格中的欄位
class MaiColumn {
  final String id; // 欄位唯一識別符
  final String name; // 欄位名稱
  final ColumnType type; // 欄位類型
  final bool isRequired; // 是否為必填欄位
  final bool isUnique; // 是否為唯一值
  final bool isSystem; // 是否為系統欄位(如Title)
  final dynamic defaultValue; // 默認值
  final Map<String, dynamic> options; // 欄位特定配置選項

  MaiColumn({
    required this.id,
    required this.name,
    required this.type,
    this.isRequired = false,
    this.isUnique = false,
    this.isSystem = false,
    this.defaultValue,
    required this.options,
  });

  factory MaiColumn.fromJson(Map<String, dynamic> json) {
    return MaiColumn(
      id: json['id'],
      name: json['name'],
      type: ColumnType.values.firstWhere(
        (e) => e.toString().split('.').last == (json['type'] ?? 'text'),
        orElse: () => ColumnType.text,
      ),
      isRequired: json['isRequired'] ?? false,
      isUnique: json['isUnique'] ?? false,
      isSystem: json['isSystem'] ?? false,
      defaultValue: json['defaultValue'],
      options: Map<String, dynamic>.from(json['options'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'isRequired': isRequired,
      'isUnique': isUnique,
      'isSystem': isSystem,
      'defaultValue': defaultValue,
      'options': options,
    };
  }
}

/// 欄位類型枚舉
enum ColumnType {
  title, // 標題欄位(系統欄位,每個表必須有且只有一個)
  text, // 文本
  richText, // 富文本
  number, // 數字
  singleSelect, // 單選
  multiSelect, // 多選
  people, // 人員
  image, // 圖片
  photo, // 照片
  file, // 文件
  link, // 連結到其他MaiTable
  date, // 日期
  datetime, // 日期時間
  checkbox, // 勾選框
  url, // 網址
  email, // 電子郵件
  phone, // 電話
  formula, // 公式
  rating, // 評分
  currency, // 貨幣
  duration, // 時長
  lookup, // 查詢
}

/// MaiRow 代表表格中的資料列
class MaiRow {
  final String id; // 資料列唯一識別符
  final DateTime createdAt; // 創建時間
  final DateTime updatedAt; // 最後更新時間
  final String createdBy; // 創建者ID
  final String updatedBy; // 最後更新者ID
  final List<MaiCell> cells; // 資料列中的所有單元格

  MaiRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
    required this.cells,
  });

  factory MaiRow.fromJson(Map<String, dynamic> json) {
    return MaiRow(
      id: json['id'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      cells: (json['cells'] as List<dynamic>?)?.map((e) => MaiCell.fromJson(e)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'cells': cells.map((e) => e.toJson()).toList(),
    };
  }
}

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

/// MaiTableLayout 代表表格視圖佈局
class MaiTableLayout {
  final String id; // 佈局唯一識別符
  final String name; // 佈局名稱
  final LayoutType type; // 佈局類型
  final Map<String, dynamic> settings; // 佈局設置
  final List<String> visibleColumns; // 可見欄位ID列表
  final String? sortBy; // 排序欄位ID
  final bool sortAscending; // 是否升序排序
  final String? filterJson; // 過濾條件JSON

  MaiTableLayout({
    required this.id,
    required this.name,
    required this.type,
    required this.settings,
    required this.visibleColumns,
    this.sortBy,
    this.sortAscending = true,
    this.filterJson,
  });

  factory MaiTableLayout.fromJson(Map<String, dynamic> json) {
    return MaiTableLayout(
      id: json['id'],
      name: json['name'],
      type: LayoutType.values.firstWhere(
        (e) => e.toString().split('.').last == (json['type'] ?? 'table'),
        orElse: () => LayoutType.table,
      ),
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
      visibleColumns: List<String>.from(json['visibleColumns'] ?? []),
      sortBy: json['sortBy'],
      sortAscending: json['sortAscending'] ?? true,
      filterJson: json['filterJson'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'settings': settings,
      'visibleColumns': visibleColumns,
      'sortBy': sortBy,
      'sortAscending': sortAscending,
      'filterJson': filterJson,
    };
  }
}

/// 佈局類型枚舉
enum LayoutType {
  table, // 表格檢視
  kanban, // 看板檢視
  calendar, // 行事曆檢視
  gallery, // 畫廊檢視
  list, // 列表檢視
  timeline, // 時間線檢視
  gantt, // 甘特圖檢視
}

/// 單選項目
class SelectOption {
  final String id; // 選項唯一識別符
  final String name; // 選項名稱
  final String color; // 選項顏色

  SelectOption({
    required this.id,
    required this.name,
    required this.color,
  });

  factory SelectOption.fromJson(Map<String, dynamic> json) {
    return SelectOption(
      id: json['id'],
      name: json['name'],
      color: json['color'] ?? '#FF0000',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
    };
  }
}

/// 多選欄位配置
class MultiSelectColumnOptions {
  final List<SelectOption> options; // 可選選項列表

  MultiSelectColumnOptions({
    required this.options,
  });

  factory MultiSelectColumnOptions.fromJson(Map<String, dynamic> json) {
    return MultiSelectColumnOptions(
      options: (json['options'] as List<dynamic>?)?.map((e) => SelectOption.fromJson(e)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'options': options.map((e) => e.toJson()).toList(),
    };
  }
}

/// 單選欄位配置
class SingleSelectColumnOptions {
  final List<SelectOption> options; // 可選選項列表

  SingleSelectColumnOptions({
    required this.options,
  });

  factory SingleSelectColumnOptions.fromJson(Map<String, dynamic> json) {
    return SingleSelectColumnOptions(
      options: (json['options'] as List<dynamic>?)?.map((e) => SelectOption.fromJson(e)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'options': options.map((e) => e.toJson()).toList(),
    };
  }
}

/// 連結欄位配置
class LinkColumnOptions {
  final String targetTableId; // 目標表格ID
  final bool allowMultiple; // 是否允許多值連結

  LinkColumnOptions({
    required this.targetTableId,
    this.allowMultiple = false,
  });

  factory LinkColumnOptions.fromJson(Map<String, dynamic> json) {
    return LinkColumnOptions(
      targetTableId: json['targetTableId'],
      allowMultiple: json['allowMultiple'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'targetTableId': targetTableId,
      'allowMultiple': allowMultiple,
    };
  }
}

/// 數字欄位配置
class NumberColumnOptions {
  final String? format; // 數字格式(貨幣,百分比等)
  final int precision; // 小數位數
  final bool allowNegative; // 是否允許負數

  NumberColumnOptions({
    this.format,
    this.precision = 2,
    this.allowNegative = true,
  });

  factory NumberColumnOptions.fromJson(Map<String, dynamic> json) {
    return NumberColumnOptions(
      format: json['format'],
      precision: json['precision'] ?? 2,
      allowNegative: json['allowNegative'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'format': format,
      'precision': precision,
      'allowNegative': allowNegative,
    };
  }
}

/// 日期時間欄位配置
class DateTimeColumnOptions {
  final bool includeTime; // 是否包含時間
  final String? format; // 日期格式
  final bool isShowOnCalendar; // 是否顯示在行事曆上
  final CalendarTitleFormat calendarTitleFormat; // 行事曆標題格式

  DateTimeColumnOptions({
    this.includeTime = true,
    this.format,
    this.isShowOnCalendar = true,
    this.calendarTitleFormat = CalendarTitleFormat.rowTitle,
  });

  factory DateTimeColumnOptions.fromJson(Map<String, dynamic> json) {
    return DateTimeColumnOptions(
      includeTime: json['includeTime'] ?? true,
      format: json['format'],
      isShowOnCalendar: json['isShowOnCalendar'] ?? true,
      calendarTitleFormat: CalendarTitleFormat.values.firstWhere(
        (e) => e.toString().split('.').last == (json['calendarTitleFormat'] ?? 'rowTitle'),
        orElse: () => CalendarTitleFormat.rowTitle,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'includeTime': includeTime,
      'format': format,
      'isShowOnCalendar': isShowOnCalendar,
      'calendarTitleFormat': calendarTitleFormat.toString().split('.').last,
    };
  }
}

/// 行事曆標題格式
enum CalendarTitleFormat {
  rowTitle, // 行標題
  rowTitleAndColumnName, // 行標題 - 時間欄位名稱
}
