import '../../auth/supabase_auth/auth_util.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const kMaxEventNameLength = 40;
const kMaxParameterLength = 100;

void logFirebaseEvent(String eventName, {Map<String?, dynamic>? parameters}) {
  // Note: You can integrate with analytics services like Posthog, Mixpanel, etc.
  // For now, this is a placeholder that just logs events
  assert(eventName.length <= kMaxEventNameLength);

  parameters ??= {};
  parameters.putIfAbsent(
      'user', () => currentUserUid.isEmpty ? 'unset' : currentUserUid);
  parameters.removeWhere((k, v) => k == null || v == null);
  final params = parameters.map((k, v) => MapEntry(k!, v));

  // Log to console in debug mode
  print('Analytics Event: $eventName with params: $params');

  // TODO: Integrate with your preferred analytics service
  // Example: Posthog, Mixpanel, Amplitude, etc.
}

void logFirebaseAuthEvent(User? user, String method) {
  final isSignup = user?.createdAt == user?.lastSignInAt;
  final authEvent = isSignup ? 'sign_up' : 'login';
  logFirebaseEvent(authEvent, parameters: {'method': method});
}
