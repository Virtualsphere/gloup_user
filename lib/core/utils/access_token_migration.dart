/// Migrates a legacy access token from [SharedPreferences] into secure storage.
///
/// Returns `true` when a legacy token was found and removed from prefs
/// (whether or not it was written to secure storage).
Future<bool> migrateLegacyAccessToken({
  required String? legacyToken,
  required Future<String?> Function() readSecure,
  required Future<void> Function(String token) writeSecure,
  required Future<void> Function() removeLegacy,
}) async {
  if (legacyToken == null || legacyToken.isEmpty) {
    return false;
  }

  final existingSecure = await readSecure();
  if (existingSecure == null || existingSecure.isEmpty) {
    await writeSecure(legacyToken);
  }

  await removeLegacy();
  return true;
}
