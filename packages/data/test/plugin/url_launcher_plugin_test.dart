import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:data/src/plugin/url_launcher_plugin.dart';

import 'url_launcher_plugin_test.mocks.dart';

@GenerateNiceMocks([MockSpec<UrlLauncherDelegate>()])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late UrlLauncherPlugin plugin;
  late MockUrlLauncherDelegate mockUrlLauncherDelegate;

  setUp(() {
    mockUrlLauncherDelegate = MockUrlLauncherDelegate();
    plugin = UrlLauncherPlugin(delegate: mockUrlLauncherDelegate);
  });

  group('UrlLauncherPlugin', () {
    test('launch returns true when launchUrl succeeds', () async {
      when(mockUrlLauncherDelegate.launch(any)).thenAnswer((_) async => true);

      final result = await plugin.launch('https://example.com');

      expect(result, isTrue);
      verify(
        mockUrlLauncherDelegate.launch(Uri.parse('https://example.com')),
      ).called(1);
    });

    test('launch returns false when launchUrl fails', () async {
      when(mockUrlLauncherDelegate.launch(any)).thenAnswer((_) async => false);

      final result = await plugin.launch('https://example.com');

      expect(result, isFalse);
      verify(
        mockUrlLauncherDelegate.launch(Uri.parse('https://example.com')),
      ).called(1);
    });

    test('canLaunch returns true when canLaunchUrl succeeds', () async {
      when(
        mockUrlLauncherDelegate.canLaunch(any),
      ).thenAnswer((_) async => true);

      final result = await plugin.canLaunch('https://example.com');

      expect(result, isTrue);
      verify(
        mockUrlLauncherDelegate.canLaunch(Uri.parse('https://example.com')),
      ).called(1);
    });

    test('canLaunch returns false when canLaunchUrl fails', () async {
      when(
        mockUrlLauncherDelegate.canLaunch(any),
      ).thenAnswer((_) async => false);

      final result = await plugin.canLaunch('https://example.com');

      expect(result, isFalse);
      verify(
        mockUrlLauncherDelegate.canLaunch(Uri.parse('https://example.com')),
      ).called(1);
    });
  });
}
