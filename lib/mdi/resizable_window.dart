import 'package:flutter/material.dart';
import 'package:flutter_app_mdi/mdi/parameter_window.dart';

class ResizableWindow extends StatefulWidget {


  final Widget body;
  final ParameterWindow parameter;

  final Function(double, double) onWindowDragged;
  final Function() onWindowDraggedStart;
  final Function(double x, double y) onWindowDraggedEnd;
  final Function(double x,double y, double width, double height) onWindowResized;
  final Widget Function(BuildContext context,Widget child)? windowBuilder;
  final VoidCallback onCloseButtonClicked;
  final Function(void Function() setState)? onUpdate;

  const ResizableWindow({super.key, required this.parameter, required this.onWindowDragged, required this.onWindowDraggedStart, required this.onWindowDraggedEnd, required this.onCloseButtonClicked, required this.body, required this.onWindowResized, this.windowBuilder, this.onUpdate});

  @override
  State<ResizableWindow> createState() => ResizableWindowState();
}

class ResizableWindowState extends State<ResizableWindow> {
  final _snapRange = 30.0;
  final _gapWidget = 2;

  double x = 0;
  double y = 0;
  double currentHeight = 400;
  double currentWidth = 400;

  @override
  void initState() {
     x = widget.parameter.x;
     y = widget.parameter.y;
     currentHeight = widget.parameter.currentHeight;
     currentWidth = widget.parameter.currentWidth;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: y,
      left: x,
      child: widget.windowBuilder?.call(context,_windowBuilder())??_windowBuilder()
    );
  }

  void rebuild() {
    setState(() {
    });
  }
  double _nearestMultiple(double number, double n) {
    n+=_gapWidget;
    double lowerMultiple = (number ~/ n) * n;
    double higherMultiple = lowerMultiple + n;
    return (number - lowerMultiple < higherMultiple - number) ? lowerMultiple : higherMultiple;
  }

  Size nearestXY(Size number, Size n) {
    double nearestWidth = _nearestMultiple(number.width, n.width);
    double nearestHeight = _nearestMultiple(number.height, n.height);
    return Size(nearestWidth, nearestHeight);
  }

  bool isCanSnap(Size current, Size snap) {
    bool isSnapX = false;
    bool isSnapY = false;

    if ((current.width < (snap.width + _snapRange)) &&
        (current.width > (snap.width - _snapRange))) {
      isSnapX = true;
    }
    if ((current.height < (snap.height + _snapRange)) &&
        (current.height > (snap.height - _snapRange))) {
      isSnapY = true;
    }
    return (isSnapY && isSnapX);
  }


  Widget _windowBuilder(){
    return SizedBox(
      width: currentWidth,
      height: currentHeight,
      child: Stack(
        children: [
          _windowBody(widget.body),
          Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragUpdate: _onHorizontalDragRight,
                onHorizontalDragEnd: (details) {
                  _onHorizontalRightDragEnd(details);
                  widget.onWindowResized(x,y,currentWidth,currentHeight);
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeLeftRight,
                  opaque: true,
                  child: Container(
                    width: 4,
                  ),
                ),
              )),
          Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: GestureDetector(
                onHorizontalDragUpdate: _onHorizontalDragLeft,
                onHorizontalDragEnd: (details) {
                  _onHorizontalLeftDragEnd(details);
                  widget.onWindowResized(x,y,currentWidth,currentHeight);
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeLeftRight,
                  opaque: true,
                  child: Container(
                    width: 4,
                  ),
                ),
              )),
          Positioned(
              left: 0,
              top: 0,
              right: 0,
              child: GestureDetector(
                onVerticalDragUpdate: _onHorizontalDragTop,
                onVerticalDragEnd: (details) {
                  _onVerticalDragTopEnd(details);
                  widget.onWindowResized(x,y,currentWidth,currentHeight);
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeUpDown,
                  opaque: true,
                  child: Container(
                    height: 4,
                  ),
                ),
              )),
          Positioned(
              left: 0,
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onVerticalDragUpdate: _onHorizontalDragBottom,
                onVerticalDragEnd: (details) {
                  _onVerticalDragBottomEnd(details);
                  widget.onWindowResized(x,y,currentWidth,currentHeight);
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeUpDown,
                  opaque: true,
                  child: Container(
                    height: 4,
                  ),
                ),
              )),
          Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onPanUpdate: _onHorizontalDragBottomRight,
                onPanEnd: (details) {
                  widget.onWindowResized(x,y,currentWidth,currentHeight);
                },
                child: const MouseRegion(
                  cursor: SystemMouseCursors.resizeUpLeftDownRight,
                  opaque: true,
                  child: SizedBox(
                    height: 6,
                    width: 6,
                  ),
                ),
              )),
          Positioned(
              bottom: 0,
              left: 0,
              child: GestureDetector(
                onPanUpdate: _onHorizontalDragBottomLeft,
                onPanEnd: (details) {
                  widget.onWindowResized(x,y,currentWidth,currentHeight);
                },
                child: const MouseRegion(
                  cursor: SystemMouseCursors.resizeUpRightDownLeft,
                  opaque: true,
                  child: SizedBox(
                    height: 6,
                    width: 6,
                  ),
                ),
              )),
          Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onPanUpdate: _onHorizontalDragTopRight,
                onPanEnd: (details) {
                  widget.onWindowResized(x,y,currentWidth,currentHeight);
                },
                child: const MouseRegion(
                  cursor: SystemMouseCursors.resizeUpRightDownLeft,
                  opaque: true,
                  child: SizedBox(
                    height: 6,
                    width: 6,
                  ),
                ),
              )),
          Positioned(
              left: 0,
              top: 0,
              child: GestureDetector(
                onPanUpdate: _onHorizontalDragTopLeft,
                onPanEnd: (details) {
                  widget.onWindowResized(x,y,currentWidth,currentHeight);
                },
                child: const MouseRegion(
                  cursor: SystemMouseCursors.resizeUpLeftDownRight,
                  opaque: true,
                  child: SizedBox(
                    height: 6,
                    width: 6,
                  ),
                ),
              )),
        ],
      ),
    );
  }

  _windowBody(Widget child) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanDown: (details) {
        setState(() {
          widget.onWindowDraggedStart();
        });
      },
      onPanUpdate: (tapInfo) {
        setState(() {
          x += tapInfo.delta.dx;
          y += tapInfo.delta.dy;
          x = x.clamp(0.0, double.infinity);
          y = y.clamp(0.0, double.infinity);
        });
        widget.onWindowDragged(tapInfo.delta.dx, tapInfo.delta.dy);
      },
      onPanEnd: (details) {
        _onWindowDragEnd();
        widget.onWindowDraggedEnd(x,y);
      },
      child: Container(
        color: Theme.of(context).canvasColor,
        child: child
      ),
    );
  }

  void _onWindowDragEnd(){
    final Size currentPosition = Size(x, y);
    const Size defaultSnap = Size(ParameterWindow.defaultWidth, ParameterWindow.defaultHeight);
    final Size nearestSnap = nearestXY(currentPosition, defaultSnap);
    bool isSnap = isCanSnap(currentPosition, nearestSnap);

    if (isSnap) {
      setState(() {
        x = nearestSnap.width;
        y = nearestSnap.height;
      });
    }
  }

  void _onVerticalDragBottomEnd(DragEndDetails details){
    double nearestSnap = _nearestMultiple(currentHeight, ParameterWindow.defaultHeight);
    if(currentHeight<(nearestSnap+_snapRange)&& currentHeight>(nearestSnap-_snapRange)){
      setState(() {
        currentHeight = nearestSnap;
      });
    }
  }

  void _onVerticalDragTopEnd(DragEndDetails details){
    double bottomPos = currentHeight + y;
    double nearestSnap = _nearestMultiple(currentHeight, ParameterWindow.defaultHeight);
    if(currentHeight<(nearestSnap+_snapRange)&& currentHeight>(nearestSnap-_snapRange)){
      setState(() {
        currentHeight = nearestSnap;
        y = bottomPos - currentHeight;
      });
    }
  }

  void _onHorizontalLeftDragEnd(DragEndDetails details){
    double rightPos = currentWidth + x;
    double nearestSnap = _nearestMultiple(currentWidth, ParameterWindow.defaultWidth);
    if(currentWidth<(nearestSnap+_snapRange)&& currentWidth>(nearestSnap-_snapRange)){
      setState(() {
        currentWidth = nearestSnap;
        x = rightPos - currentWidth;
      });
    }
  }

  void _onHorizontalRightDragEnd(DragEndDetails details){
    double nearestSnap = _nearestMultiple(currentWidth, ParameterWindow.defaultWidth);
    if(currentWidth<(nearestSnap+_snapRange)&& currentWidth>(nearestSnap-_snapRange)){
      setState(() {
        currentWidth = nearestSnap;
      });
    }
  }

  void _onHorizontalDragLeft(DragUpdateDetails details) {
    double rightPos = currentWidth + x;
    double newX = x + details.delta.dx;
    double newWidth = currentWidth - details.delta.dx;

    setState(() {
      if (newWidth < widget.parameter.minWidth) {
        currentWidth = widget.parameter.minWidth;
        x = rightPos - currentWidth;
      } else if (newX <= 0) {
        x = 0;
        currentWidth = rightPos; //why not rightPos-x? because x is 0
      } else {
        x = newX;
        currentWidth = newWidth;
        widget.onWindowDragged(details.delta.dx,0);
      }
    });
  }

  void _onHorizontalDragRight(DragUpdateDetails details) {
    setState(() {
      currentWidth += details.delta.dx;
      if (currentWidth < widget.parameter.minWidth) {
        currentWidth = widget.parameter.minWidth;
      }
    });
  }

  void _onHorizontalDragBottom(DragUpdateDetails details) {
    setState(() {
      currentHeight += details.delta.dy;
      if (currentHeight < widget.parameter.minHeight) {
        currentHeight = widget.parameter.minHeight;
      }
    });
  }

  void _onHorizontalDragTop(DragUpdateDetails details) {
    double bottomPos = currentHeight + y;
    double newY = y + details.delta.dy;
    double newHeight = currentHeight - details.delta.dy;

    setState(() {
      if (newHeight < widget.parameter.minHeight) {
        currentHeight = widget.parameter.minHeight;
        y = bottomPos - currentHeight;
      } else if (newY <= 0) {
        y = 0;
        currentHeight = bottomPos; //why not bottomPos-y? because y is 0
      } else {
        y = newY;
        currentHeight = newHeight;
        widget.onWindowDragged(0, details.delta.dy);
      }
    });
  }


  void _onHorizontalDragBottomRight(DragUpdateDetails details) {
    _onHorizontalDragRight(details);
    _onHorizontalDragBottom(details);
  }

  void _onHorizontalDragBottomLeft(DragUpdateDetails details) {
    _onHorizontalDragLeft(details);
    _onHorizontalDragBottom(details);
  }

  void _onHorizontalDragTopRight(DragUpdateDetails details) {
    _onHorizontalDragRight(details);
    _onHorizontalDragTop(details);
  }

  void _onHorizontalDragTopLeft(DragUpdateDetails details) {
    _onHorizontalDragLeft(details);
    _onHorizontalDragTop(details);
  }
}
