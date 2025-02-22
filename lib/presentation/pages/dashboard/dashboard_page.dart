import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_weather/presentation/animations/entrance_animations.dart';
import 'package:flutter_weather/presentation/widgets/widgets.dart';
import 'dashboard_page_scope.dart';

/// A dynamic dashboard displaying weather data with a refresh indicator.
///
/// As a placeholder, it shows only a loading layout and a refresh control.
/// Update this to display your actual weather data in a list, or with
/// custom widgets.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DashboardPageScope.of(context)..initialize(),
      child: const _Layout(),
    );
  }
}

class _Layout extends StatefulWidget {
  /// Creates a new [_Layout].
  const _Layout();

  @override
  State<_Layout> createState() => _LayoutState();
}

class _LayoutState extends State<_Layout> with SingleTickerProviderStateMixin {
  /// The controller which manages the entrance animations.
  late final AnimationController _entranceAnimationsController;

  /// The entrance animations for the [DashboardPage].
  late final _EntranceAnimations _entranceAnimations;

  /// Timer to start the entrance animation.
  late final Timer _entranceAnimationsStartTimer;

  /// Scroll controller used for pagination (if needed).
  final _scrollController = ScrollController();

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
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final padding = MediaQuery.paddingOf(context);
    final bottomPadding = 32 + padding.bottom;
    final topPadding = 16 + padding.top;

    final dashboard = context.watch<DashboardPageScope>();
    final isLoading = dashboard.isLoading;
    final weatherDataList = dashboard.weatherDataList;

    /// Body with a RefreshIndicator that triggers loading more weather data.
    Widget body = RefreshIndicator(
      onRefresh: dashboard.loadWeatherData,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final weatherData = weatherDataList[index];
                return ListTile(
                  leading: Image.network(
                    'https://openweathermap.org/img/wn/${weatherData.icon}@2x.png',
                    width: 48,
                    height: 48,
                    errorBuilder:
                        (context, error, stack) => const Icon(Icons.cloud),
                  ),
                  title: Text(
                    '${weatherData.temperature} °C - ${weatherData.description}',
                  ),
                  subtitle: Text('Humidity: ${weatherData.humidity}%'),
                );
              }, childCount: weatherDataList.length),
            ),
          ),
        ],
      ),
    );

    /// If still loading, show an animation with a loading indicator.
    if (isLoading) {
      body = AnimatedTranslation.vertical(
        key: Key('loading_indicator.${isLoading ? 'visible' : 'hidden'}'),
        animation: _entranceAnimations.body,
        pixels: 32,
        child: Padding(
          padding: EdgeInsets.only(bottom: topPadding),
          child: const Center(
            child: LoadingLayout(message: Text('Loading weather data...')),
          ),
        ),
      );
    }

    /// Build the overall Scaffold with an AppBar and the animated body.
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(topPadding),
        child: AppBar(
          clipBehavior: Clip.none,
          backgroundColor: WidgetStateColor.resolveWith((states) {
            return states.contains(WidgetState.scrolledUnder)
                ? colorScheme.primary.withAlpha(60)
                : Colors.transparent;
          }),
        ),
      ),
      body: AnimatedSwitcher(
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        duration: const Duration(milliseconds: 450),
        child: body,
      ),
    );
  }
}

/// The entrance animations for each item on the [DashboardPage].
class _EntranceAnimations extends EntranceAnimations {
  /// Creates a new [_EntranceAnimations].
  const _EntranceAnimations({required super.controller});

  Animation<double> get appBarButton => curvedAnimation(0.000, 0.500);
  Animation<double> get appBarTitle => curvedAnimation(0.050, 0.550);
  Animation<double> get searchBar => curvedAnimation(0.200, 0.700);
  Animation<double> get body => curvedAnimation(0.300, 0.800);
}
