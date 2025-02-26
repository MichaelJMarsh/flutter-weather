import 'dart:async';

import 'package:flutter/material.dart' hide ThemeMode;

import 'package:domain/domain.dart';
import 'package:provider/provider.dart';

import 'package:flutter_weather/presentation/animations/entrance_animations.dart';
import 'package:flutter_weather/presentation/widgets/widgets.dart';

import 'settings_page_scope.dart';
import 'widget/chip_picker.dart';

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
            child: settings.isLoading
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
                              child: _ThemePickerCard(
                                themeMode: settings.themeMode,
                                toggleThemeMode: settings.toggleThemeMode,
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
                                        labelBuilder: (option) =>
                                            option.displayText,
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
                                        initialOption: settings.temperatureUnit,
                                        labelBuilder: (option) =>
                                            option.displayText,
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

/// A card for toggling the theme between light and dark modes.
class _ThemePickerCard extends StatelessWidget {
  /// Creates a new [_ThemePickerCard].
  const _ThemePickerCard({
    required this.themeMode,
    required this.toggleThemeMode,
  });

  /// The current theme mode.
  final ThemeMode themeMode;

  /// The function to toggle the theme mode.
  final ValueChanged<bool>? toggleThemeMode;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    const animationDuration = Duration(milliseconds: 350);
    final themeDisplayText = themeMode == ThemeMode.dark ? 'Dark' : 'Light';

    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text.rich(
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                TextSpan(
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: AnimatedSize(
                        curve: Curves.fastOutSlowIn,
                        duration: animationDuration,
                        alignment: Alignment.centerLeft,
                        child: AnimatedSwitcher(
                          switchInCurve: Curves.easeIn,
                          switchOutCurve: Curves.easeOut,
                          duration: animationDuration,
                          layoutBuilder: (currentChild, previousChildren) {
                            return Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                ...previousChildren,
                                if (currentChild != null) currentChild,
                              ],
                            );
                          },
                          child: Text(
                            key: Key('theme_card_text.$themeDisplayText'),
                            themeDisplayText,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const TextSpan(text: ' Theme'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Switch(
              value: themeMode == ThemeMode.dark,
              onChanged: toggleThemeMode,
              activeColor: colorScheme.primary,
            ),
          ],
        ),
      ),
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
