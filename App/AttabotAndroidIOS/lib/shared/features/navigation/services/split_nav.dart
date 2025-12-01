import 'package:flutter/material.dart';

class SplitNav {
  static GlobalKey<NavigatorState>? rightPaneNavKey;
  static BuildContext? get rightContext => rightPaneNavKey?.currentContext;
}
