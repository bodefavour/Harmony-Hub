import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Supabase Configuration
///
/// To set up your Supabase project:
/// 1. Go to https://supabase.com and create a new project
/// 2. Copy your project URL and anon key from Project Settings > API
/// 3. Create a .env file in the root directory (copy from .env.example)
/// 4. Add your credentials to the .env file:
///    SUPABASE_URL=your_url_here
///    SUPABASE_ANON_KEY=your_key_here
/// 5. Set up your database schema in the Supabase dashboard

String get supabaseUrl =>
    dotenv.env['SUPABASE_URL'] ?? 'YOUR_SUPABASE_URL_HERE';

String get supabaseAnonKey =>
    dotenv.env['SUPABASE_ANON_KEY'] ?? 'YOUR_SUPABASE_ANON_KEY_HERE';

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
