import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Holds the raw credential returned by a social provider.
sealed class SocialCredential {}

class GoogleCredential extends SocialCredential {
  final String idToken;
  GoogleCredential(this.idToken);
}

class AppleCredential extends SocialCredential {
  final String authorizationCode;
  final String identityToken;
  final String userIdentifier;
  AppleCredential({
    required this.authorizationCode,
    required this.identityToken,
    required this.userIdentifier,
  });
}

class SocialAuthCancelled extends SocialCredential {}

class SocialAuthError extends SocialCredential {
  final String message;
  SocialAuthError(this.message);
}

/// Gets the native provider credential (token / code) from Google or Apple.
/// The actual backend call is handled by [AuthRemoteDataSource].
class SocialAuthService {
  // TODO: Set your Google client ID from Firebase / GCP console if needed
  static const _googleClientId = '';

  final _googleSignIn = GoogleSignIn(
    clientId: _googleClientId.isEmpty ? null : _googleClientId,
    scopes: ['email', 'profile'],
  );

  // ---------------------------------------------------------------------------
  // Google
  // ---------------------------------------------------------------------------

  Future<SocialCredential> getGoogleCredential() async {
    try {
      await _googleSignIn.signOut(); // Always show account picker
      final account = await _googleSignIn.signIn();

      if (account == null) return SocialAuthCancelled();

      final auth = await account.authentication;
      final idToken = auth.idToken;

      if (idToken == null) {
        return SocialAuthError('Failed to get Google ID token');
      }

      debugPrint('SocialAuthService: Google credential obtained');
      return GoogleCredential(idToken);
    } catch (e) {
      debugPrint('SocialAuthService: Google sign-in error: $e');
      return SocialAuthError(e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // Apple (iOS / macOS only)
  // ---------------------------------------------------------------------------

  Future<SocialCredential> getAppleCredential() async {
    if (!Platform.isIOS && !Platform.isMacOS) {
      return SocialAuthError('Apple Sign-In is only available on iOS / macOS');
    }

    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final authCode = credential.authorizationCode;
      final identityToken = credential.identityToken;
      final userIdentifier = credential.userIdentifier;

      if (identityToken == null || userIdentifier == null) {
        return SocialAuthError('Incomplete Apple credential');
      }

      debugPrint('SocialAuthService: Apple credential obtained');
      return AppleCredential(
        authorizationCode: authCode,
        identityToken: identityToken,
        userIdentifier: userIdentifier,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) return SocialAuthCancelled();
      debugPrint('SocialAuthService: Apple sign-in error: ${e.message}');
      return SocialAuthError(e.message);
    } catch (e) {
      debugPrint('SocialAuthService: Apple sign-in error: $e');
      return SocialAuthError(e.toString());
    }
  }
}
