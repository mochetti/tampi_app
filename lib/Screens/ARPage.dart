import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'ARCorePage.dart';
import 'ARKitPage.dart';

class ARPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() =>
      Platform.isAndroid ? ARCoreState() : ARKitState();
}
