import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:share_plus/share_plus.dart' as package;

import 'package:data/src/plugin/share_plugin.dart';

import 'share_plugin_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ShareDelegate>()])
void main() {
  late SharePlugin sharePlugin;
  late MockShareDelegate mockShareWrapper;

  setUp(() {
    mockShareWrapper = MockShareDelegate();
    sharePlugin = SharePlugin(delegate: mockShareWrapper);
  });

  group('SharePlugin', () {
    test(
      'send calls ShareDelegate.share and returns true if successful',
      () async {
        const testContent = 'Test content';
        const testSubject = 'Test subject';
        const testMessage = 'Test message';
        const testRect = Rect.fromLTWH(0, 0, 100, 100);

        when(
          mockShareWrapper.share(
            any,
            subject: anyNamed('subject'),
            sharePositionOrigin: anyNamed('sharePositionOrigin'),
          ),
        ).thenAnswer(
          (_) async => const package.ShareResult(
            'success',
            package.ShareResultStatus.success,
          ),
        );

        final result = await sharePlugin.send(
          content: testContent,
          subject: testSubject,
          message: testMessage,
          sharePositionOrigin: testRect,
        );

        expect(result, isTrue);
        verify(
          mockShareWrapper.share(
            '$testMessage\n\n$testContent',
            subject: testSubject,
            sharePositionOrigin: testRect,
          ),
        ).called(1);
      },
    );

    test('send returns false if ShareResult is unavailable', () async {
      const testContent = 'Unavailable content';
      const testRect = Rect.fromLTWH(0, 0, 100, 100);

      when(
        mockShareWrapper.share(
          any,
          subject: anyNamed('subject'),
          sharePositionOrigin: anyNamed('sharePositionOrigin'),
        ),
      ).thenAnswer(
        (_) async => const package.ShareResult(
          'unavailable',
          package.ShareResultStatus.unavailable,
        ),
      );

      final result = await sharePlugin.send(
        content: testContent,
        sharePositionOrigin: testRect,
      );

      expect(result, isFalse);
      verify(
        mockShareWrapper.share(
          testContent,
          subject: null,
          sharePositionOrigin: testRect,
        ),
      ).called(1);
    });
  });
}
