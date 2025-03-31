abstract class ColorPickerEvent {}

/// 初始化顏色選擇器事件
class InitializeColorPicker extends ColorPickerEvent {
  final String? initialColor;

  InitializeColorPicker({this.initialColor});
}

/// 選擇顏色事件
class SelectColor extends ColorPickerEvent {
  final String color;

  SelectColor(this.color);
}

/// 打開顏色選擇器事件
class OpenColorPicker extends ColorPickerEvent {}

/// 關閉顏色選擇器事件
class CloseColorPicker extends ColorPickerEvent {}
