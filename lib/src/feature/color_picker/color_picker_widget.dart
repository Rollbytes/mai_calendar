import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'color_picker_bloc.dart';
import 'color_picker_event.dart';
import 'color_picker_state.dart';
import 'hex_color_adapter.dart';

class ColorPickerWidget extends StatefulWidget {
  final ColorPickerBloc colorPickerBloc;
  final Function(String)? onColorChanged;
  final String? initialColor;

  const ColorPickerWidget({
    super.key,
    required this.colorPickerBloc,
    this.onColorChanged,
    this.initialColor,
  });

  @override
  State<ColorPickerWidget> createState() => _ColorPickerWidgetState();
}

class _ColorPickerWidgetState extends State<ColorPickerWidget> {
  late ColorPickerBloc _colorPickerBloc;

  @override
  void initState() {
    super.initState();
    _colorPickerBloc = widget.colorPickerBloc;
    if (widget.initialColor != null) {
      _colorPickerBloc.add(SelectColor(widget.initialColor!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ColorPickerBloc, ColorPickerState>(
      bloc: widget.colorPickerBloc,
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            widget.colorPickerBloc.add(OpenColorPicker());
            _showColorPicker(context, state);
          },
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 18,
                height: 18,
                padding: const EdgeInsets.all(0),
                margin: const EdgeInsets.all(0),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: HexColor.parse(state.selectedColor),
                ),
              ),
              const SizedBox(width: 16),
              const Text("顏色", style: TextStyle(fontSize: 14)),
            ],
          ),
        );
      },
    );
  }

  void _showColorPicker(BuildContext context, ColorPickerState state) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Dialog(
          alignment: Alignment.centerRight,
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.25,
            vertical: 24.0,
          ),
          child: Container(
            width: 200,
            margin: const EdgeInsets.symmetric(horizontal: 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4.0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView(
              shrinkWrap: true,
              children: state.selectableColors.entries.map((entry) {
                final String colorCode = entry.key;
                final String colorName = entry.value;
                final Color colorObj = HexColor.parse(colorCode);
                return InkWell(
                  onTap: () {
                    widget.colorPickerBloc.add(SelectColor(colorCode));
                    if (widget.onColorChanged != null) {
                      widget.onColorChanged!(colorCode);
                    }
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: colorObj,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            colorName,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const Spacer(),
                          if (colorCode == state.selectedColor) const Icon(Icons.check, color: Colors.grey, size: 18),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
