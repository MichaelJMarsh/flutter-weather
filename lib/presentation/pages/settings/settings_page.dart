import 'dart:async';

import 'package:flutter/material.dart' hide ThemeMode;

import 'package:domain/domain.dart';
import 'package:provider/provider.dart';

import 'package:flutter_weather/presentation/animations/entrance_animations.dart';
import 'package:flutter_weather/presentation/widgets/widgets.dart';

import 'settings_page_scope.dart';

/// A page displaying the list of available settings.
class SettingsPage extends StatefulWidget {
  /// Creates a new [SettingsPage].
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  /// The controller which manages the entrance animations.
  late final AnimationController _entranceAnimationsController;

  /// The entrance animations for the [DashboardPage].
  late final _EntranceAnimations _entranceAnimations;

  /// Timer to start the entrance animation.
  late final Timer _entranceAnimationsStartTimer;

  @override
  void initState() {
    super.initState();

    _entranceAnimationsController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _entranceAnimations = _EntranceAnimations(
      controller: _entranceAnimationsController,
    );

    _entranceAnimationsStartTimer = Timer(
      const Duration(milliseconds: 200),
      _entranceAnimationsController.forward,
    );
  }

  @override
  void dispose() {
    _entranceAnimationsStartTimer.cancel();
    _entranceAnimationsController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SettingsPageScope.of(context)..initialize(),
      builder: (context, _) {
        final colorScheme = Theme.of(context).colorScheme;

        final settings = context.watch<SettingsPageScope>();

        return Scaffold(
          appBar: AppBar(
            clipBehavior: Clip.none,
            title: AnimatedTranslation.vertical(
              animation: _entranceAnimations.appBarTitle,
              pixels: 40,
              child: const Text('Settings'),
            ),
            leading: AnimatedTranslation.horizontal(
              animation: _entranceAnimations.appBarButton,
              pixels: -32,
              child: IconButton(
                onPressed: Navigator.of(context).pop,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
          ),
          body: AnimatedSwitcher(
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            duration: const Duration(milliseconds: 350),
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                alignment: Alignment.topCenter,
                children: [
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              );
            },
            child:
                settings.isLoading
                    ? const Padding(
                      padding: EdgeInsets.only(bottom: kToolbarHeight),
                      child: LoadingLayout(
                        message: Text('Loading settings data...'),
                      ),
                    )
                    : CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              AnimatedTranslation.vertical(
                                animation: _entranceAnimations.themeCard,
                                pixels: 40,
                                child: Card(
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(24),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Dark Mode',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Switch(
                                          value:
                                              settings.themeMode ==
                                              ThemeMode.dark,
                                          onChanged: settings.toggleThemeMode,
                                          activeColor: colorScheme.primary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              AnimatedTranslation.vertical(
                                animation: _entranceAnimations.unitsCard,
                                pixels: 40,
                                child: Card(
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(24),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    child: Column(
                                      children: [
                                        const Text('Time Format'),
                                        ChipPicker<TimeFormat>(
                                          options: TimeFormat.values,
                                          initialOption: settings.timeFormat,
                                          labelBuilder:
                                              (option) => option.displayText,
                                          onOptionSelected:
                                              settings.setTimeFormat,
                                        ),
                                        Divider(
                                          color: colorScheme.onSurface
                                              .withValues(alpha: 0.16),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text('Temperature Unit'),
                                        ChipPicker<TemperatureUnit>(
                                          options: TemperatureUnit.values,
                                          initialOption:
                                              settings.temperatureUnit,
                                          labelBuilder:
                                              (option) => option.displayText,
                                          onOptionSelected:
                                              settings.setTemperatureUnit,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              AnimatedTranslation.vertical(
                                animation: _entranceAnimations.appVersion,
                                pixels: 40,
                                child: Center(
                                  child: Text(
                                    'Version 1.0.0',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.48,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                          ),
                        ),
                      ],
                    ),
          ),
        );
      },
    );
  }
}

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8,
      children:
          widget.options.map((option) {
            final isSelected = option == _selectedOption;
            final labelColor =
                isSelected ? colorScheme.onPrimary : colorScheme.onSurface;

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

/// The entrance animations for each item on the [SettingsPage].
class _EntranceAnimations extends EntranceAnimations {
  /// Creates a new [_EntranceAnimations].
  const _EntranceAnimations({required super.controller});

  Animation<double> get appBarButton => curvedAnimation(0.000, 0.500);
  Animation<double> get appBarTitle => curvedAnimation(0.050, 0.550);

  Animation<double> get themeCard => curvedAnimation(0.150, 0.650);

  Animation<double> get unitsCard => curvedAnimation(0.250, 0.750);

  Animation<double> get appVersion => curvedAnimation(0.350, 0.850);
}
