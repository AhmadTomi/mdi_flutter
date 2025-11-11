import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_mdi/mdi/parameter_window.dart';
import 'package:flutter_app_mdi/mdi/resizable_window/resizable_window.dart';
import 'package:flutter_app_mdi/mdi/resizable_window/resizable_window_controller.dart';

import '../mdi_tab/mdi_tab_controller.dart';

class MdiController extends ChangeNotifier{
  final Map<String, ResizeableWindowController> _controllers = {};


  final List<Widget> _cachedWindowWidgets = [];
  List<Widget> get windowWidgets => _cachedWindowWidgets;



  Size screenSize = Size.zero;
  Size mdiSize = Size.zero;

  bool isMaximize = false;
  bool hasFocus = false;

  final ScrollController horizontalController = ScrollController();
  final ScrollController verticalController = ScrollController();
  final ScrollController verticalScrollBarController = ScrollController();

  final MdiTabController tabMenuController = MdiTabController();

  final _debouncer = _Debouncer(milliseconds: 100);

  ResizeableWindowController? get frontWindow => (_controllers.isNotEmpty) ?_controllers.values.last : null;

  void init(){
    verticalController.addListener(() {
      if (verticalScrollBarController.hasClients && !verticalScrollBarController.position.isScrollingNotifier.value) {
        verticalScrollBarController.jumpTo(verticalController.position.pixels);
      }
    });
    verticalScrollBarController.addListener(() {
      if (verticalController.hasClients && !verticalController.position.isScrollingNotifier.value) {
        verticalController.jumpTo(verticalScrollBarController.position.pixels);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      tabMenuController.init();
      requestLastWindowFocus();
    });
  }

  @override
  void dispose() {
    horizontalController.dispose();
    verticalController.dispose();
    verticalScrollBarController.dispose();
    tabMenuController.dispose();
    _debouncer.dispose();

    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    super.dispose();
  }

  bool onKeyEvent(KeyEvent event){
    if(event is KeyDownEvent ){
      if(HardwareKeyboard.instance.isControlPressed){
        if(HardwareKeyboard.instance.isAltPressed){
          if(HardwareKeyboard.instance.isShiftPressed){
            // CTRL + ALT + SHIFT + Arrow for move window Position
            final window = frontWindow;
            if(window!=null){
              if(event.logicalKey == LogicalKeyboardKey.arrowRight){
                window.moveRight();
                return true;
              }
              if(event.logicalKey == LogicalKeyboardKey.arrowLeft){
                window.moveLeft();
                return true;
              }
              if(event.logicalKey == LogicalKeyboardKey.arrowUp){
                window.moveUp();
                return true;
              }
              if(event.logicalKey == LogicalKeyboardKey.arrowDown){
                window.moveDown();
                return true;
              }

              /*var param = _windowParameters[windowKey]?.clone;
                  if(param!=null){
                    scrollTo(param.x, param.y);
                  }*/
            }
          }

          // CTRL + ALT + Arrow for move focus

          if(event.logicalKey == LogicalKeyboardKey.arrowRight){
            moveFocusNext();
            return true;
          }
          if(event.logicalKey == LogicalKeyboardKey.arrowLeft){
            moveFocusPrevious();
            return true;
          }

        }
      }

      if(event.logicalKey == LogicalKeyboardKey.escape){
        removeFrontWindow();
        return true;
      }
    }
    return false;
  }

  void _addController(String tag,ResizeableWindowController controller,Widget widget){
    _controllers[tag]=controller;
    tabMenuController.addTab(tag, controller);
    _cachedWindowWidgets.add(widget);
  }
  void _removeController(String tag){
    final controller = _controllers[tag];
    if (controller != null) {
      _controllers.remove(tag);
      tabMenuController.removeTab(tag);
      _cachedWindowWidgets.removeWhere((w) => w.key == ValueKey(tag));
      controller.dispose();
    }
  }

  void addWindow({
    required ParameterWindow parameter,
    required Widget Function(ResizeableWindowController controller) child,
    bool notify=true
  })
  {
    final tag = parameter.tag;
    if(_controllers.containsKey(tag)) {
      throw Exception('Tag $tag already exists');
    }

    if(parameter.x==-1 || parameter.y==-1){
      //Centering Widget
      final double centerX = max(0,(screenSize.width-parameter.currentWidth)/2)-(Random().nextInt(60)-30);
      final double centerY = max(0,(screenSize.height-parameter.currentHeight)/2)-(Random().nextInt(60)-30);
      parameter.updateParameter(posX: centerX,posY: centerY);
    }


    final newController = ResizeableWindowController(
      parameter: parameter,
      child: child,
    );

    newController.initAction(
      onClose: (tag) => removeWindow(tag),
      toggleMaximize: (action) {
        isMaximize = !isMaximize;
        action(screenSize);
        notifyListeners();
      },
      onFocusChange: (hasFocus) {
        if (newController.isDisposed) return;
        if (this.hasFocus) {
          newController.toggleMaximize(screenSize, (hasFocus && isMaximize));
        }

        if (hasFocus) {
          bringToFront(tag);
        }
      },
      onPositionChange: (position, size) {
        _debouncer.run(() {
          final needUpdate = calculateUpdateScreenSize();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if(!isMaximize)scrollTo(newController.xBound, newController.yBound);
          });

          if(needUpdate) notifyListeners();
        });

      },
    );
    final newWidget = ResizableWindow(
      key: ValueKey(tag), // The key is crucial!
      controller: newController,
    );
    _addController(tag, newController, newWidget);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      newController.requestFocus();
    });
    if(notify)notifyListeners();
  }

  void removeWindow(String tag) {
    if(tag.isEmpty) return;
    _removeController(tag);
    calculateUpdateScreenSize();
    notifyListeners();
    requestLastWindowFocus();
  }

  void removeFrontWindow(){
    removeWindow(frontWindow?.tag??'');
  }

  void removeAllWindows(){
    final tags = _controllers.keys.toList();
    for (var tag in tags) {
      _removeController(tag);
    }
    calculateUpdateScreenSize();
    notifyListeners();
  }

  bool calculateUpdateScreenSize() {
    var valuesX = _controllers.values.map((c) => c.x+c.currentWidth);
    var valuesY = _controllers.values.map((c) => c.y+c.currentHeight);

    double maxX = valuesX.fold(0.0, max);
    double maxY = valuesY.fold(0.0, max);

    final double newX = maxX.clamp(screenSize.width, double.infinity);
    final double newY = maxY.clamp(screenSize.height, double.infinity);

    final newMdiSize = Size(newX, newY);
    if(newMdiSize != mdiSize) {
      mdiSize = newMdiSize;
      return true;
    }
    return false;
  }

  void bringToFront(String tag) {

    if (!_controllers.containsKey(tag)) return;

    final controller = _controllers.remove(tag);
    _controllers[tag] = controller!;


    final widget =
    _cachedWindowWidgets.firstWhere((w) => w.key == ValueKey(tag));
    _cachedWindowWidgets.remove(widget);
    _cachedWindowWidgets.add(widget);


    if(!isMaximize)scrollTo(controller.x, controller.y);
    notifyListeners();
  }

  void requestLastWindowFocus(){
    if(_controllers.isEmpty) return;
    final controller = _controllers.values.last;
    controller.requestFocus();
  }

  void moveFocusNext(){
    if(_controllers.length<2) return;
    final listTab = tabMenuController.tabControllers;
    final currentIndex = listTab.indexWhere((element) => element.tag==frontWindow?.tag);
    if(currentIndex == -1) return;
    int newIndex = currentIndex+1;
    if(newIndex>=listTab.length) newIndex=0;
    listTab[newIndex].requestFocus();
  }

  void moveFocusPrevious(){
    if(_controllers.length<2) return;
    final listTab = tabMenuController.tabControllers;
    final currentIndex = listTab.indexWhere((element) => element.tag==frontWindow?.tag);
    if(currentIndex == -1) return;
    int newIndex = currentIndex-1;
    if(newIndex<0) newIndex=listTab.length-1;
    listTab[newIndex].requestFocus();
  }

  Duration _calculateDuration(ScrollController scrollController, double targetPosition){
    final distance = (targetPosition - scrollController.position.pixels).abs();
    const double speedMultiplier = 0.5;
    int maxDuration = 500;
    int minDuration = 300;
    return Duration(milliseconds: (distance * speedMultiplier).toInt().clamp(minDuration, maxDuration));
  }

  Future<void> scrollTo(double x, double y) async {
    // Get position objects for easier access and clarity
    final posH = horizontalController.position;
    final posV = verticalController.position;

    // --- Logic Improvement: Clearer Variable Names ---
    // Calculate the boundaries of the currently visible area
    final visibleLeft = posH.pixels;
    final visibleTop = posV.pixels; // <-- BUG FIX: Was 'mixY'

    // Calculate the latest coordinate an item's top-left corner can be at
    // and still be fully visible on screen.
    final latestVisibleX = visibleLeft + screenSize.width - ParameterWindow.defaultMinWidth;
    final latestVisibleY = visibleTop + screenSize.height - ParameterWindow.defaultMinHeight;

    // Futures to hold our animation tasks
    Future<void> horizontalScroll = Future.value();
    Future<void> verticalScroll = Future.value();

    // Check if horizontal scrolling is needed
    if (x < visibleLeft || x > latestVisibleX) {
      // --- Logic Improvement: Clamping ---
      // Clamp the target to be within the scroll controller's limits
      final targetX = x.clamp(posH.minScrollExtent, posH.maxScrollExtent);

      // --- Suggestion: Consistent Animation ---
      // The 'x == 0' check for jumpTo() is jarring.
      // Consider replacing this 'if/else' with just the animateTo() call.
      horizontalScroll = horizontalController.animateTo(
        targetX,
        duration: _calculateDuration(horizontalController, targetX),
        curve: Curves.easeInOut, // <-- SUGGESTION: Use a consistent curve
      );
    }

    // Check if vertical scrolling is needed
    if (y < visibleTop || y > latestVisibleY) {
      // Clamp the target to be within the scroll controller's limits
      final targetY = y.clamp(posV.minScrollExtent, posV.maxScrollExtent);

      if (y == 0) {
        verticalController.jumpTo(0);
      } else {
        verticalScroll = verticalController.animateTo(
          targetY,
          duration: _calculateDuration(verticalController, targetY),
          curve: Curves.easeInOut, // <-- SUGGESTION: Use a consistent curve
        );
      }
    }

    // --- BUG FIX: Parallel Animation ---
    // Run both animations at the same time for a smooth diagonal scroll.
    await Future.wait([horizontalScroll, verticalScroll]);
  }

  void toggleMaximize(){
    isMaximize = !isMaximize;
    frontWindow?.toggleMaximize(screenSize,isMaximize);
    notifyListeners();
  }

}

class _Debouncer {
  final int milliseconds;
  Timer? _timer;

  _Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    // If a timer is already active, cancel it
    if (_timer != null) {
      _timer!.cancel();
    }

    // Start a new timer
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}