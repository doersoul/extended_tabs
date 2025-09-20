import 'package:flutter/widgets.dart';

/// todo check, add by doersoul@126.com
final SpringDescription _spring = SpringDescription.withDampingRatio(
  mass: 1,
  stiffness: 512,
);

const ScrollPhysics extendedScrollPhysics = ExtendedScrollPhysics();

class ExtendedScrollPhysics extends ScrollPhysics {
  const ExtendedScrollPhysics({super.parent});

  @override
  ScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return ExtendedScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => _spring;
}
