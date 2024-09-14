import '/flutter_flow/flutter_flow_util.dart';
import 'onboarding_edit_widget.dart' show OnboardingEditWidget;
import 'package:flutter/material.dart';

class OnboardingEditModel extends FlutterFlowModel<OnboardingEditWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for PageView widget.
  PageController? pageViewController;

  int get pageViewCurrentIndex => pageViewController != null &&
          pageViewController!.hasClients &&
          pageViewController!.page != null
      ? pageViewController!.page!.round()
      : 0;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
