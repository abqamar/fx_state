import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

enum FxUiFamily { material, cupertino }

/// iOS visual flavor. "liquidGlass" is enabled when iOS >= 26 is detected
/// (best-effort parsing), or when forced via [FxPlatformConfig].
enum FxIosFlavor { cupertino, liquidGlass }

class FxPlatformConfig {
  const FxPlatformConfig({
    this.forceUiFamily,
    this.forceIosFlavor,
    this.assumeIos26OrLater = false,
  });

  /// Force UI family regardless of platform.
  final FxUiFamily? forceUiFamily;

  /// Force iOS flavor regardless of detected OS version.
  final FxIosFlavor? forceIosFlavor;

  /// If true, treats iOS as 26+ (useful for testing / unknown OS strings).
  final bool assumeIos26OrLater;

  static FxPlatformConfig? _global;
  static void setGlobal(FxPlatformConfig? cfg) => _global = cfg;
  static FxPlatformConfig? get global => _global;
}

class FxPlatform {
  FxPlatform._();

  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;

  static FxUiFamily uiFamily(BuildContext context) {
    final cfg = FxPlatformConfig.global;
    if (cfg?.forceUiFamily != null) return cfg!.forceUiFamily!;
    if (isIOS || isMacOS) return FxUiFamily.cupertino;
    return FxUiFamily.material;
  }

  /// Best-effort parse of iOS major version from Platform.operatingSystemVersion.
  static int? iosMajorVersion() {
    if (!isIOS) return null;

    final s = Platform.operatingSystemVersion;
    // common patterns: "Version 26.0", "iOS 26.0", or "26.0"
    final reg = RegExp(r'(?:iOS\s*)?(?:Version\s*)?(\d{2})\.?');
    final m = reg.firstMatch(s);
    if (m == null) return null;
    return int.tryParse(m.group(1) ?? '');
  }

  static FxIosFlavor iosFlavor(BuildContext context) {
    final cfg = FxPlatformConfig.global;
    if (cfg?.forceIosFlavor != null) return cfg!.forceIosFlavor!;
    if (!isIOS) return FxIosFlavor.cupertino;

    if (cfg?.assumeIos26OrLater == true) return FxIosFlavor.liquidGlass;

    final v = iosMajorVersion();
    if (v != null && v >= 26) return FxIosFlavor.liquidGlass;
    return FxIosFlavor.cupertino;
  }
}
