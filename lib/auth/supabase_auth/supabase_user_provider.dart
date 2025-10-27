import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rxdart/rxdart.dart';
import '../base_auth_user_provider.dart';

export '../base_auth_user_provider.dart';

class HarmonyHubSupabaseUser extends BaseAuthUser {
  HarmonyHubSupabaseUser(this.user);
  User? user;

  @override
  bool get loggedIn => user != null;

  @override
  AuthUserInfo get authUserInfo => AuthUserInfo(
        uid: user?.id,
        email: user?.email,
        displayName: user?.userMetadata?['display_name'] as String?,
        photoUrl: user?.userMetadata?['avatar_url'] as String?,
        phoneNumber: user?.phone,
      );

  @override
  Future? delete() async {
    // Supabase doesn't have a direct delete user method from client
    // This needs to be done via Supabase admin API or database trigger
    // For now, we'll sign out
    await Supabase.instance.client.auth.signOut();
  }

  @override
  Future? updateEmail(String email) async {
    await Supabase.instance.client.auth.updateUser(
      UserAttributes(email: email),
    );
  }

  @override
  Future? sendEmailVerification() async {
    // Supabase automatically sends verification emails
    // If you need to resend, you can call:
    if (user?.email != null) {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: user!.email!,
      );
    }
  }

  @override
  bool get emailVerified {
    return user?.emailConfirmedAt != null;
  }

  @override
  Future refreshUser() async {
    final response = await Supabase.instance.client.auth.refreshSession();
    user = response.user;
  }

  static BaseAuthUser fromUser(User? user) => HarmonyHubSupabaseUser(user);
}

Stream<BaseAuthUser> harmonyHubSupabaseUserStream() =>
    Supabase.instance.client.auth.onAuthStateChange
        .map<AuthState>((event) => event)
        .startWith(AuthState(
          AuthChangeEvent.initialSession,
          Supabase.instance.client.auth.currentSession,
        ))
        .debounce((event) => event.session == null && !loggedIn
            ? TimerStream(true, const Duration(seconds: 1))
            : Stream.value(event))
        .map<BaseAuthUser>(
      (event) {
        currentUser = HarmonyHubSupabaseUser(event.session?.user);
        return currentUser!;
      },
    );
