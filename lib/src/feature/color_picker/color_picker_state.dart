import 'package:equatable/equatable.dart';

/// 顏色選擇器狀態
class ColorPickerState extends Equatable {
  /// 當前選擇的顏色
  final String selectedColor;

  /// 可選擇的顏色映射 (顏色代碼 -> 名稱)
  final Map<String, String> availableColors;

  /// 是否顯示顏色選擇器
  final bool isPickerVisible;

  const ColorPickerState({
    required this.selectedColor,
    required this.availableColors,
    this.isPickerVisible = false,
  });

  /// 初始狀態
  factory ColorPickerState.initial() {
    return ColorPickerState(
      selectedColor: '#FF6B6B', // 預設紅色
      availableColors: {
        '#FF6B6B': '紅色',
        '#FF7878': '粉紅色',
        '#FF8C66': '橙色',
        '#FFA366': '杏橙色',
        '#FFC847': '明亮黃',
        '#66C589': '翠綠色',
        '#6B8EFF': '湛藍色',
        '#759AD4': '淡藍色',
        '#937ACD': '紫色',
        '#B98ED8': '薰衣草紫',
        //這裡以下的顏色不用顯示在選擇器上
        '#4A6572': '深藍灰',
        '#344955': '深藍',
        '#232F34': '深灰',
        '#F9AA33': '橙黃',
        '#D75A4A': '深紅色',
        '#7E57C2': '紫色',
        '#26A69A': '藍綠',
        '#5D4037': '棕色',
        '#546E7A': '藍灰',
        '#6D4C41': '深棕',
        '#00897B': '深綠',
        '#5C6BC0': '藍紫',
        '#EF6C00': '深橙',
        '#C0392B': '深紅',
        '#2980B9': '藍色',
      },
    );
  }

  /// 複製並更新狀態
  ColorPickerState copyWith({
    String? selectedColor,
    Map<String, String>? availableColors,
    bool? isPickerVisible,
  }) {
    return ColorPickerState(
      selectedColor: selectedColor ?? this.selectedColor,
      availableColors: availableColors ?? this.availableColors,
      isPickerVisible: isPickerVisible ?? this.isPickerVisible,
    );
  }

  /// 可供選擇的顏色（僅顯示在選擇器中的顏色）
  Map<String, String> get selectableColors => Map.fromEntries(
        availableColors.entries.where((entry) => [
              '#FF6B6B',
              '#FF7878',
              '#FF8C66',
              '#FFA366',
              '#FFC847',
              '#66C589',
              '#6B8EFF',
              '#759AD4',
              '#937ACD',
              '#B98ED8',
            ].contains(entry.key)),
      );

  @override
  List<Object?> get props => [selectedColor, availableColors, isPickerVisible];
}
