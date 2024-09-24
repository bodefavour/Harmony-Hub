import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'app_open_model.dart';
export 'app_open_model.dart';

class AppOpenWidget extends StatefulWidget {
  const AppOpenWidget({super.key});

  @override
  State<AppOpenWidget> createState() => _AppOpenWidgetState();
}

class _AppOpenWidgetState extends State<AppOpenWidget> {
  late AppOpenModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AppOpenModel());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'appOpen'});
    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      logFirebaseEvent('APP_OPEN_PAGE_appOpen_ON_INIT_STATE');

      context.pushNamed('onboarding');
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFF060303),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Harmony Hub ',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Readex Pro',
                        color: const Color(0xFFE74B08),
                        fontSize: 50.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
