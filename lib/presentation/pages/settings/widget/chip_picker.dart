import 'package:flutter/material.dart';

/// A picker for selecting a single option from a list of options.
class ChipPicker<T> extends StatefulWidget {
  /// Creates a new [ChipPicker].
  const ChipPicker({
    super.key,
    required this.initialOption,
    required this.options,
    required this.onOptionSelected,
    required this.labelBuilder,
  });

  /// The initial selected option.
  final T initialOption;

  /// The available options.
  final List<T> options;

  /// The function called when an option is selected.
  final ValueChanged<T> onOptionSelected;

  /// A builder function to build a label for the given option.
  final String Function(T option) labelBuilder;

  @override
  State<ChipPicker<T>> createState() => _ChipPickerState<T>();
}

class _ChipPickerState<T> extends State<ChipPicker<T>> {
  /// The currently selected option.
  late T _selectedOption;

  @override
  void initState() {
    super.initState();

    _selectedOption = widget.initialOption;
  }

  /// Selects the given [option].
  void _selectChip(T option) {
    if (option == _selectedOption) return;

    setState(() => _selectedOption = option);

    widget.onOptionSelected(option);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = colorScheme.brightness == Brightness.dark;

    // Blend the primary color with white or black based on the brightness.
    final selectedColor = Color.alphaBlend(
      colorScheme.primary.withValues(alpha: 0.8),
      isDarkMode ? Colors.white : Colors.black,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8,
      children:
          widget.options.map((option) {
            final isSelected = option == _selectedOption;

            final labelColor =
                isSelected ? selectedColor : colorScheme.onSurface;

            return ChoiceChip(
              label: Text(widget.labelBuilder(option)),
              selected: isSelected,
              onSelected: (_) => _selectChip(option),
              selectedColor: colorScheme.primary.withValues(alpha: 0.24),
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: labelColor,
              ),
            );
          }).toList(),
    );
  }
}
