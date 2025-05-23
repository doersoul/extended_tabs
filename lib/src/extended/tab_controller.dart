import 'package:flutter/material.dart';

/// todo check, add by doersoul@126.com
class ExtendedTabController extends TabController {
  bool jump = false;

  ExtendedTabController({
    super.initialIndex = 0,
    super.animationDuration,
    required super.length,
    required super.vsync,
  });
}
