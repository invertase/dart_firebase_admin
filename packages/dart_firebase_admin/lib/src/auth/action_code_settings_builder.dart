part of '../auth.dart';

class ActionCodeSettingsIos {
  ActionCodeSettingsIos(this.bundleId);

  /// Defines the required iOS bundle ID of the app where the link should be
  /// handled if the application is already installed on the device.
  final String bundleId;
}

class ActionCodeSettingsAndroid {
  ActionCodeSettingsAndroid({
    required this.packageName,
    this.installApp,
    this.minimumVersion,
  });

  /// Defines the required Android package name of the app where the link should be
  /// handled if the Android app is installed.
  final String packageName;

  /// Whether to install the Android app if the device supports it and the app is
  /// not already installed.
  final bool? installApp;

  /// The Android minimum version if available. If the installed app is an older
  /// version, the user is taken to the GOogle Play Store to upgrade the app.
  final String? minimumVersion;
}

/// This is the interface that defines the required continue/state URL with
/// optional Android and iOS bundle identifiers.
class ActionCodeSettings {
  ActionCodeSettings({
    required this.url,
    this.handleCodeInApp,
    this.iOS,
    this.android,
    this.dynamicLinkDomain,
  });

  /// Defines the link continue/state URL, which has different meanings in
  /// different contexts:
  /// <ul>
  /// <li>When the link is handled in the web action widgets, this is the deep
  ///     link in the `continueUrl` query parameter.</li>
  /// <li>When the link is handled in the app directly, this is the `continueUrl`
  ///     query parameter in the deep link of the Dynamic Link.</li>
  /// </ul>
  final String url;

  /// Whether to open the link via a mobile app or a browser.
  /// The default is false. When set to true, the action code link is sent
  /// as a Universal Link or Android App Link and is opened by the app if
  /// installed. In the false case, the code is sent to the web widget first
  /// and then redirects to the app if installed.
  final bool? handleCodeInApp;

  /// Defines the iOS bundle ID. This will try to open the link in an iOS app if it
  /// is installed.
  final ActionCodeSettingsIos? iOS;

  /// Defines the Android package name. This will try to open the link in an
  /// android app if it is installed. If `installApp` is passed, it specifies
  /// whether to install the Android app if the device supports it and the app is
  /// not already installed. If this field is provided without a `packageName`, an
  /// error is thrown explaining that the `packageName` must be provided in
  /// conjunction with this field. If `minimumVersion` is specified, and an older
  /// version of the app is installed, the user is taken to the Play Store to
  /// upgrade the app.
  final ActionCodeSettingsAndroid? android;

  /// Defines the dynamic link domain to use for the current link if it is to be
  /// opened using Firebase Dynamic Links, as multiple dynamic link domains can be
  /// configured per project. This field provides the ability to explicitly choose
  /// configured per project. This fields provides the ability explicitly choose
  /// one. If none is provided, the oldest domain is used by default.
  final String? dynamicLinkDomain;
}

class _ActionCodeSettingsBuilder {
  _ActionCodeSettingsBuilder(ActionCodeSettings actionCodeSettings)
      : _continueUrl = actionCodeSettings.url,
        _canHandleCodeInApp = actionCodeSettings.handleCodeInApp ?? false,
        _dynamicLinkDomain = actionCodeSettings.dynamicLinkDomain,
        _ibi = actionCodeSettings.iOS?.bundleId,
        _apn = actionCodeSettings.android?.packageName,
        _amv = actionCodeSettings.android?.minimumVersion,
        _installApp = actionCodeSettings.android?.installApp ?? false {
    if (Uri.tryParse(actionCodeSettings.url) == null) {
      throw FirebaseAuthAdminException(AuthClientErrorCode.invalidContinueUri);
    }

    final dynamicLinkDomain = actionCodeSettings.dynamicLinkDomain;
    if (dynamicLinkDomain != null && dynamicLinkDomain.isEmpty) {
      throw FirebaseAuthAdminException(
        AuthClientErrorCode.invalidDynamicLinkDomain,
      );
    }

    final ios = actionCodeSettings.iOS;
    if (ios != null) {
      if (ios.bundleId.isEmpty) {
        throw FirebaseAuthAdminException(
          AuthClientErrorCode.invalidArgument,
          '"ActionCodeSettings.iOS.bundleId" must be a valid non-empty string.',
        );
      }
    }

    final android = actionCodeSettings.android;
    if (android != null) {
      if (android.packageName.isEmpty) {
        throw FirebaseAuthAdminException(
          AuthClientErrorCode.invalidArgument,
          '"ActionCodeSettings.android.packageName" must be a valid non-empty string.',
        );
      }
      final minimumVersion = android.minimumVersion;
      if (minimumVersion != null && minimumVersion.isEmpty) {
        throw FirebaseAuthAdminException(
          AuthClientErrorCode.invalidArgument,
          '"ActionCodeSettings.android.minimumVersion" must be a valid non-empty string.',
        );
      }
    }
  }

  final String _continueUrl;
  final String? _apn;
  final String? _amv;
  final bool _installApp;
  final String? _ibi;
  final bool _canHandleCodeInApp;
  final String? _dynamicLinkDomain;

  void buildRequest(
    auth1.GoogleCloudIdentitytoolkitV1GetOobCodeRequest request,
  ) {
    request.continueUrl = _continueUrl;
    request.canHandleCodeInApp = _canHandleCodeInApp;
    request.dynamicLinkDomain = _dynamicLinkDomain;
    request.androidPackageName = _apn;
    request.androidMinimumVersion = _amv;
    request.androidInstallApp = _installApp;
    request.iOSBundleId = _ibi;
  }
}
