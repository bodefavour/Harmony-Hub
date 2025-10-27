import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'auth/supabase_auth/supabase_user_provider.dart';
import 'auth/supabase_auth/auth_util.dart';

import 'backend/supabase/supabase_config.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();
  await initSupabase();

  await FlutterFlowTheme.initialize();

  final appState = FFAppState(); // Initialize FFAppState
  await appState.initializePersistedState();

  runApp(ChangeNotifierProvider(
    create: (context) => appState,
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = FlutterFlowTheme.themeMode;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;

  late Stream<BaseAuthUser> userStream;

  @override
  void initState() {
    super.initState();

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);

    print('DEBUG: initState - Initial loading: ${_appStateNotifier.loading}');
    print('DEBUG: initState - Initial loggedIn: ${_appStateNotifier.loggedIn}');

    // Initialize with a default user immediately to unblock splash screen
    _appStateNotifier.update(HarmonyHubSupabaseUser(null));
    print('DEBUG: After update - loading: ${_appStateNotifier.loading}, loggedIn: ${_appStateNotifier.loggedIn}');

    // Then listen for actual auth changes
    userStream = harmonyHubSupabaseUserStream()
      ..listen((user) {
        print('DEBUG: Auth stream received user: ${user.loggedIn}');
        _appStateNotifier.update(user);
      });

    // Hide splash screen after brief delay
    Future.delayed(
      const Duration(milliseconds: 1000),
      () {
        print('DEBUG: Stopping splash screen - loading before: ${_appStateNotifier.loading}');
        _appStateNotifier.stopShowingSplashImage();
        print('DEBUG: Stopping splash screen - loading after: ${_appStateNotifier.loading}');
      },
    );
  }

  void setThemeMode(ThemeMode mode) => safeSetState(() {
        _themeMode = mode;
        FlutterFlowTheme.saveThemeMode(mode);
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Harmony Hub',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', '')],
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: false,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: false,
      ),
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}
