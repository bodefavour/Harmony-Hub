import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase Configuration
///
/// To set up your Supabase project:
/// 1. Go to https://supabase.com and create a new project
/// 2. Copy your project URL and anon key from Project Settings > API
/// 3. Replace the placeholders below with your actual credentials
/// 4. Set up your database schema in the Supabase dashboard

const String supabaseUrl = 'YOUR_SUPABASE_URL_HERE';
const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY_HERE';

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
    realtimeClientOptions: const RealtimeClientOptions(
      logLevel: RealtimeLogLevel.info,
    ),
    storageOptions: const StorageClientOptions(
      retryAttempts: 10,
    ),
  );
}

/// Get the Supabase client instance
SupabaseClient get supabase => Supabase.instance.client;
