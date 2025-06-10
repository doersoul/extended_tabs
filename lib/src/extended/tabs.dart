import 'package:extended_tabs/src/extended/page_view.dart';
import 'package:extended_tabs/src/extended/tab_controller.dart';
import 'package:extended_tabs/src/gestures/link_controller.dart';
import 'package:extended_tabs/src/gestures/link_scroll_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

part 'package:extended_tabs/src/official/tabs.dart';

const ScrollPhysics _defaultScrollPhysics = NeverScrollableScrollPhysics();

/// todo check, add by doersoul@126.com
typedef ExtendedTransformer = Widget Function(Widget cld, int idx, double pos);

class ExtendedTabBarView extends _TabBarView {
  const ExtendedTabBarView({
    super.key,
    required super.children,
    required super.controller,
    // extendedScrollPhysics
    required super.physics,
    super.dragStartBehavior = DragStartBehavior.start,
    super.viewportFraction = 1.0,
    super.clipBehavior = Clip.hardEdge,
    this.cacheExtent = 0,
    this.link = true,
    this.shouldIgnorePointerWhenScrolling = false,
    this.scrollDirection = Axis.horizontal,
    this.keepTab = false,
    this.onTabChanging,
    this.onTabActive,
    this.onDragTab,
    this.transformer,
  });

  /// cache page count
  /// default is 0.
  /// if cacheExtent is 1, it has two pages in cache
  final int cacheExtent;

  /// if link is true and current tabbarview over scroll,
  /// it will check and scroll ancestor or child tabbarView.
  /// default is true
  final bool link;

  /// todo check, remove by doersoul@126.com
  /// The PageController inside, [PageController.initialPage] should the same as [TabController.initialIndex]
  /// final LinkPageController? pageController;

  /// Whether the contents of the widget should ignore [PointerEvent] inputs.
  ///
  /// Setting this value to true prevents the use from interacting with the
  /// contents of the widget with pointer events. The widget itself is still
  /// interactive.
  ///
  /// For example, if the scroll position is being driven by an animation, it
  /// might be appropriate to set this value to ignore pointer events to
  /// prevent the user from accidentally interacting with the contents of the
  /// widget as it animates. The user will still be able to touch the widget,
  /// potentially stopping the animation.
  ///
  ///
  /// if true, child can't accept event before [ExtendedPageView],[ExtendedScrollable] stop scroll.
  ///
  ///
  /// if false, child can accept event before [ExtendedPageView],[ExtendedScrollable] stop scroll.
  /// notice: we don't know there are any issues if we don't ignore [PointerEvent] inputs when it's scrolling.
  ///
  ///
  /// Two way to solve issue that child can't hittest before [PageView] stop scroll.
  /// 1. set [shouldIgnorePointerWhenScrolling] false
  /// 2. use LessSpringClampingScrollPhysics to make animation quickly
  ///
  /// default is true.
  final bool shouldIgnorePointerWhenScrolling;

  /// The axis along which the tab view scrolls.
  ///
  /// Defaults to [Axis.horizontal].
  final Axis scrollDirection;

  /// todo check, add by doersoul@126.com
  final bool keepTab;

  /// todo check, add by doersoul@126.com
  final ValueChanged<double>? onTabChanging;

  /// todo check, add by doersoul@126.com
  final ValueChanged<int>? onTabActive;

  /// todo check, add by doersoul@126.com
  final ValueChanged<bool>? onDragTab;

  /// todo check, add by doersoul@126.com
  final ExtendedTransformer? transformer;

  @override
  State<ExtendedTabBarView> createState() => ExtendedTabBarViewState();
}

class ExtendedTabBarViewState extends _TabBarViewState<ExtendedTabBarView> {
  /// todo check, add by doersoul@126.com
  final ValueNotifier<double> _position = ValueNotifier(-1);

  /// todo check, add by doersoul@126.com
  int _currentTabBarViewIndex = 0;

  @override
  bool get link => widget.link;

  @override
  LinkScrollControllerMixin get linkScrollController =>
      _pageController as LinkPageController;

  @override
  ScrollPhysics? get physics => widget.physics;

  @override
  Axis get scrollDirection => widget.scrollDirection;

  @override
  void didChangeDependencies() {
    _updateTabController();
    _currentIndex = _controller!.index;
    _currentTabBarViewIndex = _controller!.index;

    // todo check, update by doersoul@126.com
    _pageController = LinkPageController(
      initialPage: _currentIndex ?? 0,
      viewportFraction: widget.viewportFraction,
      keepPage: widget.keepTab,
    );

    // todo check, add by doersoul@126.com
    _pageController.addListener(_pageListener);

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant ExtendedTabBarView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // todo check, add by doersoul@126.com
    if (widget.controller != oldWidget.controller) {
      _currentTabBarViewIndex = _controller!.index;
    }

    // todo check, remove by doersoul@126.com
    // if ((widget.pageController != null &&
    //         widget.pageController != oldWidget.pageController) ||
    //     widget.viewportFraction != oldWidget.viewportFraction) {
    //   _pageController = widget.pageController ??
    //       LinkPageController(
    //         initialPage: _currentIndex ?? 0,
    //         viewportFraction: widget.viewportFraction,
    //       );
    // }

    if (widget.physics != oldWidget.physics) {
      updatePhysics();
    }

    if (oldWidget.scrollDirection != widget.scrollDirection ||
        oldWidget.physics != widget.physics) {
      initGestureRecognizers();
    }
  }

  /// todo check, add by doersoul@126.com
  @override
  void dispose() {
    _pageController.removeListener(_pageListener);
    _pageController.dispose();

    _position.dispose();

    super.dispose();
  }

  @override
  ScrollPhysics? getScrollPhysics() {
    // todo check，update by doersoul@126.com
    return _defaultScrollPhysics.applyTo(
      widget.physics == null
          ? const ClampingScrollPhysics()
          : const ClampingScrollPhysics().applyTo(widget.physics),
    );
  }

  @override
  // ignore: unnecessary_overrides
  void linkParent<S extends StatefulWidget, T extends LinkScrollState<S>>() {
    super.linkParent<ExtendedTabBarView, ExtendedTabBarViewState>();
  }

  /// todo check, add by doersoul@126.com
  @override
  _updateChildren() {
    if (widget.transformer != null) {
      final List<Widget> children = [];
      for (int index = 0; index < widget.children.length; index++) {
        final Widget item = widget.children[index];

        children.add(
          AnimatedBuilder(
            animation: _position,
            builder: (BuildContext context, Widget? child) {
              return widget.transformer!.call(child!, index, _position.value);
            },
            child: item,
          ),
        );
      }

      _childrenWithKey = KeyedSubtree.ensureUniqueKeysForList(children);
    } else {
      _childrenWithKey = KeyedSubtree.ensureUniqueKeysForList(widget.children);
    }
  }

  /// todo check, add by doersoul@126.com
  void _pageListener() {
    _position.value = linkScrollController.offset;

    widget.onDragTab?.call(linkScrollController.hasDrag);

    double? page = _pageController.page;
    if (page != null && page != _currentTabBarViewIndex) {
      widget.onTabChanging?.call(page);

      int round = page.round();
      if (round != _currentTabBarViewIndex) {
        _currentTabBarViewIndex = round;

        widget.onTabActive?.call(round);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(() {
      if (_controller!.length != widget.children.length) {
        throw FlutterError(
            'Controller\'s length property (${_controller!.length}) does not match the \n'
            'number of tabs (${widget.children.length}) present in TabBar\'s tabs property.');
      }
      return true;
    }());

    final result = NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: _handleGlowNotification,
        child: ExtendedPageView(
          dragStartBehavior: widget.dragStartBehavior,
          controller: _pageController,
          cacheExtent: widget.cacheExtent,
          scrollDirection: widget.scrollDirection,
          physics: usedScrollPhysics,
          shouldIgnorePointerWhenScrolling:
              widget.shouldIgnorePointerWhenScrolling,
          children: _childrenWithKey,
        ),
      ),
    );

    return buildGestureDetector(child: result);
  }

  bool _handleGlowNotification(OverscrollIndicatorNotification notification) {
    if (notification.depth == 0 &&
        !(_pageController as LinkPageController).isSelf) {
      notification.disallowIndicator();
      return true;
    }
    return false;
  }
}
