import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bcrypt/bcrypt.dart';

import '../config/push_config.dart';
import '../config/supabase_config.dart';
import 'background_notification_service.dart';
import 'profile_service.dart';
import 'push_notification_service.dart';
import 'session_service.dart';
import 'supabase_core.dart';

/// Handles authentication: sign-in, sign-out, and password changes.
///
/// Separated from profile and course logic (SRP).
class AuthService {
  AuthService._();

  static const _recoveryFailureMessage =
      'We could not verify those account details.';

  /// Sign in by making an HTTP POST request to /api/auth/login.
  ///
  /// Returns a Map with keys: `success`, `user_id`, `role`, `email`, `message`.
  static Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    final client = HttpClient();
    final normalizedEmail = email.trim().toLowerCase();
    try {
      final uri = Uri.parse('${SupabaseConfig.backendUrl}/api/auth/login');
      final request = await client
          .postUrl(uri)
          .timeout(const Duration(seconds: 15));
      request.headers.contentType = ContentType.json;
      request.headers.set('x-client-type', 'mobile');
      request.write(
        jsonEncode({'email': normalizedEmail, 'password': password}),
      );

      final response = await request.close().timeout(
        const Duration(seconds: 15),
      );
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode != 200) {
        try {
          final errJson = jsonDecode(responseBody);
          return {
            'success': false,
            'message':
                errJson['error'] ?? 'Login failed (${response.statusCode})',
          };
        } catch (_) {
          return {
            'success': false,
            'message': 'Login failed with status code ${response.statusCode}',
          };
        }
      }

      final resJson = jsonDecode(responseBody);
      if (resJson['success'] != true || resJson['data'] == null) {
        return {
          'success': false,
          'message': resJson['error'] ?? 'Invalid email or password',
        };
      }

      final data = resJson['data'] as Map<String, dynamic>;
      final userId = (data['id'] ?? '').toString();
      final role = (data['role'] ?? '').toString().toUpperCase();
      final userEmail = (data['email'] ?? normalizedEmail).toString();
      final token = (data['token'] ?? '').toString();

      await _saveSuccessfulSignIn(
        userId: userId,
        email: userEmail,
        role: role,
        token: token.isEmpty ? null : token,
      );

      return {
        'success': true,
        'user_id': userId,
        'role': role,
        'email': userEmail,
      };
    } on TimeoutException {
      return _signInDirectlyWithSupabase(
        email: normalizedEmail,
        password: password,
      );
    } on SocketException {
      return _signInDirectlyWithSupabase(
        email: normalizedEmail,
        password: password,
      );
    } on HttpException {
      return _signInDirectlyWithSupabase(
        email: normalizedEmail,
        password: password,
      );
    } on HandshakeException {
      return _signInDirectlyWithSupabase(
        email: normalizedEmail,
        password: password,
      );
    } catch (e) {
      return {'success': false, 'message': 'Connection error: ${e.toString()}'};
    } finally {
      client.close();
    }
  }

  static Future<Map<String, dynamic>> _signInDirectlyWithSupabase({
    required String email,
    required String password,
  }) async {
    try {
      final profile = await SupabaseCore.from('profiles')
          .select('user_id, email, role, password_hash, is_active')
          .eq('email', email)
          .maybeSingle()
          .timeout(const Duration(seconds: 15));

      if (profile == null) {
        return {'success': false, 'message': 'Invalid email or password'};
      }

      final isActive = profile['is_active'] as bool? ?? false;
      if (!isActive) {
        return {
          'success': false,
          'message': 'Account is deactivated. Contact admin.',
        };
      }

      final passwordHash = profile['password_hash'] as String? ?? '';
      if (passwordHash.isEmpty || !BCrypt.checkpw(password, passwordHash)) {
        return {'success': false, 'message': 'Invalid email or password'};
      }

      final userId = (profile['user_id'] ?? '').toString();
      final role = (profile['role'] ?? '').toString().toUpperCase();
      final profileEmail = (profile['email'] ?? email).toString();

      if (userId.isEmpty || role.isEmpty) {
        return {
          'success': false,
          'message': 'Account profile is incomplete. Contact admin.',
        };
      }

      await _saveSuccessfulSignIn(
        userId: userId,
        email: profileEmail,
        role: role,
      );

      unawaited(
        SupabaseCore.from('profiles')
            .update({'last_login': DateTime.now().toUtc().toIso8601String()})
            .eq('user_id', userId)
            .then((_) {})
            .catchError((_) {}),
      );

      return {
        'success': true,
        'user_id': userId,
        'role': role,
        'email': profileEmail,
      };
    } on TimeoutException {
      return {
        'success': false,
        'message':
            'Sign in timed out. Please check your connection and try again.',
      };
    } catch (_) {
      return {
        'success': false,
        'message':
            'Could not reach the login service. Please check your connection and try again.',
      };
    }
  }

  static Future<void> _saveSuccessfulSignIn({
    required String userId,
    required String email,
    required String role,
    String? token,
  }) async {
    await SessionService.saveSession(
      userId: userId,
      email: email,
      role: role,
    ).timeout(const Duration(seconds: 5));

    final prefs = await SupabaseCore.ensurePrefs();
    if (token == null || token.isEmpty) {
      await prefs.remove('user_token');
    } else {
      await prefs.setString('user_token', token);
    }

    PushConfig.loginUser(userId);
    // Keep login responsive even if FCM token registration is slow.
    unawaited(
      PushNotificationService.syncUserIdentity()
          .timeout(const Duration(seconds: 5))
          .catchError((_) {}),
    );
  }

  /// Sign out – clears saved session.
  static Future<void> signOut() async {
    await BackgroundNotificationService.stop();
    PushConfig.logoutUser();
    await PushNotificationService.clearUserIdentity();
    ProfileService.clearCache();
    await SessionService.clearSession();
  }

  /// Change password: verify current password, then update hash.
  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final verification = await verifyCurrentPassword(
        currentPassword: currentPassword,
      );
      if (verification['success'] != true) {
        return verification;
      }

      final userId = SessionService.currentUserId;
      if (userId == null) {
        return {'success': false, 'message': 'Not logged in'};
      }

      final newHash = BCrypt.hashpw(newPassword, BCrypt.gensalt());
      await SupabaseCore.from('profiles')
          .update({
            'password_hash': newHash,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('user_id', userId);

      return {'success': true, 'message': 'Password changed successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  /// Verifies the current user's password without mutating the session.
  static Future<Map<String, dynamic>> verifyCurrentPassword({
    required String currentPassword,
  }) async {
    final userId = SessionService.currentUserId;
    if (userId == null) {
      return {'success': false, 'message': 'Not logged in'};
    }

    try {
      final profile = await SupabaseCore.from(
        'profiles',
      ).select('password_hash').eq('user_id', userId).maybeSingle();

      if (profile == null) {
        return {'success': false, 'message': 'Profile not found'};
      }

      final storedHash = profile['password_hash'] as String? ?? '';
      if (!BCrypt.checkpw(currentPassword, storedHash)) {
        return {'success': false, 'message': 'Current password is incorrect'};
      }

      return {'success': true, 'message': 'Password verified'};
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  /// Recovers a forgotten password using email plus institutional identity.
  static Future<Map<String, dynamic>> resetForgottenPassword({
    required String email,
    required String verificationValue,
    required String newPassword,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedVerification = verificationValue.trim().toUpperCase();

    if (normalizedEmail.isEmpty ||
        normalizedVerification.isEmpty ||
        newPassword.length < 6) {
      return {'success': false, 'message': _recoveryFailureMessage};
    }

    try {
      final profile = await SupabaseCore.from('profiles')
          .select('user_id, role, is_active')
          .eq('email', normalizedEmail)
          .maybeSingle()
          .timeout(const Duration(seconds: 15));

      if (profile == null) {
        return {'success': false, 'message': _recoveryFailureMessage};
      }

      final isActive = profile['is_active'] as bool? ?? false;
      if (!isActive) {
        return {
          'success': false,
          'message': 'Account is deactivated. Contact admin.',
        };
      }

      final userId = (profile['user_id'] ?? '').toString();
      final role = (profile['role'] ?? '').toString().toUpperCase();

      late final String table;
      late final String column;
      switch (role) {
        case 'STUDENT':
          table = 'students';
          column = 'roll_no';
          break;
        case 'TEACHER':
        case 'HEAD':
          table = 'teachers';
          column = 'teacher_uid';
          break;
        default:
          return {
            'success': false,
            'message': 'Password recovery is not available for this account.',
          };
      }

      final identityRow = await SupabaseCore.from(
        table,
      ).select(column).eq('user_id', userId).maybeSingle();

      if (identityRow == null) {
        return {'success': false, 'message': _recoveryFailureMessage};
      }

      final storedValue = (identityRow[column] ?? '')
          .toString()
          .trim()
          .toUpperCase();
      if (storedValue != normalizedVerification) {
        return {'success': false, 'message': _recoveryFailureMessage};
      }

      final newHash = BCrypt.hashpw(newPassword, BCrypt.gensalt());
      await SupabaseCore.from('profiles')
          .update({
            'password_hash': newHash,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('user_id', userId);

      return {'success': true, 'message': 'Password reset successfully'};
    } on TimeoutException {
      return {
        'success': false,
        'message':
            'Password reset timed out. Please check your connection and try again.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }
}
