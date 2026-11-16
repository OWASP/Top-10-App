import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:top_10_app/features/accessibility/system_accessibility.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('top_10_app/accessibility');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('asks the platform to open accessibility settings', () async {
    String? method;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          method = call.method;
          return null;
        });

    expect(await openSystemAccessibilitySettings(), isTrue);
    expect(method, 'openAccessibilitySettings');
  });

  test('returns false when the platform handler is missing', () async {
    expect(await openSystemAccessibilitySettings(), isFalse);
  });

  test('returns false when the platform call fails', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          throw PlatformException(code: 'unavailable');
        });

    expect(await openSystemAccessibilitySettings(), isFalse);
  });
}
