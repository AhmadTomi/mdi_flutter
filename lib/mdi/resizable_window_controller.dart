import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_app_mdi/mdi/parameter_window.dart';

class ResizeableWindowController extends ChangeNotifier{
  final ParameterWindow parameter;
  final void Function(Size position, Size size)? onPositionChange;
  final Widget Function(ResizeableWindowController controller) child;
  void Function (bool hasFocus)? onFocusChange;
  void Function(String tag)? _onClose;
  void Function(void Function(Size screenSize) action)? _toggleMaximize;

  ResizeableWindowController(
      {
        required this.parameter,
        this.onPositionChange,
        double? snapRange,
        double? widgetPadding,
        required this.child,

      }):snapRange = snapRange??30, 
        widgetPadding = 0.0
  {
    x = parameter.x;
    y = parameter.y;
    currentHeight = parameter.currentHeight;
    currentWidth = parameter.currentWidth;
  }

  void initAction({
    void Function (bool hasFocus)? onFocusChange,
    void Function(String tag)?onClose,
    void Function(void Function(Size screenSize))?toggleMaximize,
}){
    this.onFocusChange = onFocusChange;
    _onClose = onClose;
    _toggleMaximize = toggleMaximize;
  }

  double x = 0;
  double y = 0;
  double currentHeight = 400;
  double currentWidth = 400;

  FocusScopeNode? focusScopeNode;
  
  bool isMaximized = false;
  Size lastSize = const Size(0,0);
  Size lastPosition = const Size(0,0);
  Size screenSize = const Size(0, 0);


  bool get hasFocus => focusScopeNode?.hasFocus==true;
  String get tag => parameter.tag;
  String get title => parameter.title;

  late final double snapRange;
  late final double widgetPadding;

  void close(){
    _onClose?.call(parameter.tag);
  }

  void positionChangeAction(){
    onPositionChange?.call(Size(x, y),Size(currentWidth, currentHeight));
  }

  void requestFocus(){
    if(focusScopeNode!=null && focusScopeNode?.hasFocus==false){
      focusScopeNode?.requestScopeFocus();
    }
  }

  void moveLeft(){
    if(isMaximized)return;
      x = max(0, _nearestMultiple(x-ParameterWindow.defaultWidth,ParameterWindow.defaultWidth));
      y = max(0, _nearestMultiple(y,ParameterWindow.defaultMinHeight));
      notifyListeners();
  }
  void moveRight(){
    if(isMaximized)return;
    x = max(0, _nearestMultiple(x+ParameterWindow.defaultWidth,ParameterWindow.defaultWidth));
    y = max(0, _nearestMultiple(y,ParameterWindow.defaultMinHeight));
      notifyListeners();
  }
  void moveUp(){
    if(isMaximized)return;
      y = max(0, _nearestMultiple(y-ParameterWindow.defaultMinHeight,ParameterWindow.defaultMinHeight));
      x = max(0, _nearestMultiple(x,ParameterWindow.defaultWidth));
      notifyListeners();
  }
  void moveDown(){
    if(isMaximized)return;
    y = max(0, _nearestMultiple(y+ParameterWindow.defaultMinHeight,ParameterWindow.defaultMinHeight));
    x = max(0, _nearestMultiple(x,ParameterWindow.defaultWidth));
    notifyListeners();
  }

  double _nearestMultiple(double number, double n) {
    double lowerMultiple = (number ~/ n) * n;
    double higherMultiple = lowerMultiple + n;
    return (number - lowerMultiple < higherMultiple - number) ? lowerMultiple : higherMultiple;
  }

  void updateParameter({required double x, required double y, required currentHeight, required currentWidth}){
      x = x;
      y = y;
      currentHeight = currentHeight;
      currentWidth = currentWidth;
      notifyListeners();
  }

  void checkSnap(Size current,Size snapN) {
    //calculate nearest snap area;
    final snapWidth = _nearestMultiple(current.width, snapN.width);
    final snapHeight = _nearestMultiple(current.height, snapN.height);

    // function to cek condition
    bool isInRange(double value, double target){
      return (value - snapRange) < target && target < (value + snapRange);
    }

    if(isInRange(current.width, snapWidth) && isInRange(current.height, snapHeight)){
        x = snapWidth;
        y = snapHeight;
        notifyListeners();
    }
  }

  void onWindowDragEnd(){
    final Size currentPosition = Size(x, y);
    Size defaultSnap = Size(ParameterWindow.defaultWidth, ParameterWindow.defaultHeight/4);
    checkSnap(currentPosition,defaultSnap);
  }

  void onVerticalDragBottomEnd(DragEndDetails details){
    double nearestSnap = _nearestMultiple(currentHeight, ParameterWindow.defaultHeight/4);
    if(currentHeight<(nearestSnap+snapRange)&& currentHeight>(nearestSnap-snapRange)){
        currentHeight = nearestSnap;
    }
  }

  void onVerticalDragTopEnd(DragEndDetails details){
    double bottomPos = currentHeight + y;
    double nearestSnap = _nearestMultiple(currentHeight, ParameterWindow.defaultHeight/4);
    if(currentHeight<(nearestSnap+snapRange)&& currentHeight>(nearestSnap-snapRange)){
        currentHeight = nearestSnap;
        y = bottomPos - currentHeight;
    }
  }

  void onHorizontalLeftDragEnd(DragEndDetails details){
    double rightPos = currentWidth + x;
    double nearestSnap = _nearestMultiple(currentWidth, ParameterWindow.defaultWidth);
    if(currentWidth<(nearestSnap+snapRange)&& currentWidth>(nearestSnap-snapRange)){
        currentWidth = nearestSnap;
        x = rightPos - currentWidth;
    }
  }

  void onHorizontalRightDragEnd(DragEndDetails details){
    double nearestSnap = _nearestMultiple(currentWidth, ParameterWindow.defaultWidth);
    if(currentWidth<(nearestSnap+snapRange)&& currentWidth>(nearestSnap-snapRange)){
        currentWidth = nearestSnap;
    }
  }

  void onHorizontalDragLeft(DragUpdateDetails details) {
    double rightPos = currentWidth + x;
    double newX = x + details.delta.dx;
    double newWidth = currentWidth - details.delta.dx;

      if (newWidth < parameter.minWidth) {
        currentWidth = parameter.minWidth;
        x = rightPos - currentWidth;
      } else if (newX <= 0) {
        x = 0;
        currentWidth = rightPos; //why not rightPos-x? because x is 0
      } else {
        x = newX;
        currentWidth = newWidth;
      }
  }

  void onHorizontalDragRight(DragUpdateDetails details) {
      currentWidth += details.delta.dx;
      if (currentWidth < parameter.minWidth) {
        currentWidth = parameter.minWidth;
      }
      notifyListeners();
  }

  void onHorizontalDragBottom(DragUpdateDetails details) {
      currentHeight += details.delta.dy;
      if (currentHeight < parameter.minHeight) {
        currentHeight = parameter.minHeight;
      }
  }

  void onHorizontalDragTop(DragUpdateDetails details) {
    double bottomPos = currentHeight + y;
    double newY = y + details.delta.dy;
    double newHeight = currentHeight - details.delta.dy;
      if (newHeight < parameter.minHeight) {
        currentHeight = parameter.minHeight;
        y = bottomPos - currentHeight;
      } else if (newY <= 0) {
        y = 0;
        currentHeight = bottomPos; //why not bottomPos-y? because y is 0
      } else {
        y = newY;
        currentHeight = newHeight;
      }
  }

  void onHorizontalDragBottomRight(DragUpdateDetails details) {
    onHorizontalDragRight(details);
    onHorizontalDragBottom(details);
  }

  void onHorizontalDragBottomLeft(DragUpdateDetails details) {
    onHorizontalDragLeft(details);
    onHorizontalDragBottom(details);
  }

  void onHorizontalDragTopRight(DragUpdateDetails details) {
    onHorizontalDragRight(details);
    onHorizontalDragTop(details);
  }

  void onHorizontalDragTopLeft(DragUpdateDetails details) {
    onHorizontalDragLeft(details);
    onHorizontalDragTop(details);
  }

  void toggleMaximize(Size screenSize,[bool? isMaximize]){

    if(isMaximize==isMaximized) return;

    if(isMaximized){
      x = lastPosition.width;
      y = lastPosition.height;
      currentWidth = lastSize.width;
      currentHeight = lastSize.height;

    }
    else{
      lastPosition = Size(x, y);
      lastSize = Size(currentWidth, currentHeight);

      x = 0;
      y = 0;
      currentWidth = screenSize.width;
      currentHeight = screenSize.height;
    }
    isMaximized =!isMaximized;

    notifyListeners();
  }
  Widget dragWidget({required Widget child, bool canDoubleClick = true}){
    return GestureDetector(
      supportedDevices: const {
        PointerDeviceKind.mouse,
      },
      onTap:isMaximized?null: () {
        if(canDoubleClick){
          int now = DateTime.now().millisecondsSinceEpoch;
          /*if (now - lastTap < 300) {
            consecutiveTaps++;
            if (consecutiveTaps >= 2) {
              setState(() {
                widget.onMaximize((width, height) {
                  if(currentWidth>=(width-widgetPadding) && currentHeight>=(height-widgetPadding)){
                    x = lastPosition.width;
                    y = lastPosition.height;
                    currentWidth = lastSize.width;
                    currentHeight = lastSize.height;

                    parameter.setMaximize(false);
                    return false;
                  }

                  //save current state
                  lastPosition = Size(controller.x, controller.y);
                  lastSize = Size(controller.currentWidth, controller.currentHeight);

                  //change to fullscreen
                  parameter.setMaximize(true);
                  controller.x = 0;
                  controller.y = 0;
                  controller.currentWidth = width-controller.widgetPadding;
                  controller.currentHeight = height-controller.widgetPadding;
                  return true;
                });
                widget.onWindowResized(x,y,currentWidth,currentHeight);
              });
            }
          }
          consecutiveTaps = 1;
          lastTap = now;*/
        }
        requestFocus();
      },
      onDoubleTap: () {
        _toggleMaximize?.call((screenSize) => toggleMaximize(screenSize));
      },
      onPanDown:isMaximized?null: (details) {
        requestFocus();
      },
      onPanUpdate: isMaximized?null: (tapInfo) {
        x += tapInfo.delta.dx;
        y += tapInfo.delta.dy;
        x = x.clamp(0.0, double.infinity);
        y = y.clamp(0.0, double.infinity);
        notifyListeners();
      },
      onPanEnd: isMaximized?null: (details) {
        onWindowDragEnd();
        positionChangeAction();
      },
      child: child,
    );
  }

}