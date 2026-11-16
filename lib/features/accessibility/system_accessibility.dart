import 'package:flutter/services.dart';

const MethodChannel _channel = MethodChannel('top_10_app/accessibility');

/// Opens Android's accessibility settings, where TalkBack and other screen
/// readers are enabled.
///
/// Android does not allow one app to switch an accessibility service on, so the
/// system settings screen is the only supported route.
Future<bool> openSystemAccessibilitySettings() async {
  try {
    await _channel.invokeMethod<void>('openAccessibilitySettings');
    return true;
  } on PlatformException {
    return false;
  } on MissingPluginException {
    return false;
  }
}
