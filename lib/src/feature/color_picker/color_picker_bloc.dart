
import 'package:flutter_bloc/flutter_bloc.dart';

import 'color_picker_event.dart';
import 'color_picker_state.dart';

class ColorPickerBloc extends Bloc<ColorPickerEvent, ColorPickerState> {
  ColorPickerBloc() : super(ColorPickerState.initial()) {
    on<InitializeColorPicker>(_onInitializeColorPicker);
    on<SelectColor>(_onSelectColor);
    on<OpenColorPicker>(_onOpenColorPicker);
    on<CloseColorPicker>(_onCloseColorPicker);
  }

  void _onInitializeColorPicker(InitializeColorPicker event, Emitter<ColorPickerState> emit) {
    if (event.initialColor != null) {
      emit(state.copyWith(
        selectedColor: event.initialColor!,
      ));
    }
  }

  void _onSelectColor(
    SelectColor event,
    Emitter<ColorPickerState> emit,
  ) {
    emit(state.copyWith(selectedColor: event.color, isPickerVisible: false));
  }

  void _onOpenColorPicker(OpenColorPicker event, Emitter<ColorPickerState> emit) {
    emit(state.copyWith(isPickerVisible: true));
  }

  void _onCloseColorPicker(CloseColorPicker event, Emitter<ColorPickerState> emit) {
    emit(state.copyWith(isPickerVisible: false));
  }
}
