import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:url_launcher/url_launcher.dart';

/// Forces a Google Play Immediate in-app update when a newer version is
/// available. Android / Play-installed builds only.
class ForceUpdateService {
  ForceUpdateService._();

  static const _playStorePackageId = 'com.gloup.userapp';
  static bool _inProgress = false;

  /// Checks Play for an update and starts a blocking Immediate flow when
  /// allowed. Safe to call on cold start and on [AppLifecycleState.resumed].
  /// Returns `true` if Play Immediate update UI was started successfully.
  static Future<bool> checkAndForceUpdate() async {
    if (kIsWeb || !Platform.isAndroid) return false;
    if (_inProgress) return false;

    _inProgress = true;
    try {
      final info = await InAppUpdate.checkForUpdate();
      debugPrint('ForceUpdate: $info');

      // Resume a mid-flight Immediate update (required by Play).
      if (info.updateAvailability ==
          UpdateAvailability.developerTriggeredUpdateInProgress) {
        await InAppUpdate.performImmediateUpdate();
        return true;
      }

      if (info.updateAvailability != UpdateAvailability.updateAvailable) {
        return false;
      }

      if (info.immediateUpdateAllowed) {
        final result = await InAppUpdate.performImmediateUpdate();
        if (result == AppUpdateResult.success) return true;
        // Denied/failed — fall through so UpgradeAlert / store listing can help.
        await _openPlayStoreListing();
        return false;
      }

      // Update exists but Immediate is not allowed — send user to Play Store.
      await _openPlayStoreListing();
      return false;
    } on MissingPluginException catch (e) {
      // Older store builds (e.g. 2.8.8) were released without this plugin.
      // Rely on UpgradeAlert (Dart-only) instead.
      debugPrint('ForceUpdate: plugin missing (use UpgradeAlert): $e');
      return false;
    } on PlatformException catch (e) {
      // Local/debug installs are not from Play: API is unavailable.
      debugPrint('ForceUpdate: PlatformException ${e.code} ${e.message}');
      return false;
    } catch (e) {
      debugPrint('ForceUpdate: $e');
      return false;
    } finally {
      _inProgress = false;
    }
  }

  static Future<void> _openPlayStoreListing() async {
    final market =
        Uri.parse('market://details?id=$_playStorePackageId');
    final web = Uri.parse(
      'https://play.google.com/store/apps/details?id=$_playStorePackageId',
    );

    if (await canLaunchUrl(market)) {
      await launchUrl(market, mode: LaunchMode.externalApplication);
      return;
    }
    await launchUrl(web, mode: LaunchMode.externalApplication);
  }
}
