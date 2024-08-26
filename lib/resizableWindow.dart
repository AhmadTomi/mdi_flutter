import 'package:flutter/material.dart';

class ResizableWindow extends StatefulWidget {
  double currentHeight = 400;
  double defaultHeight = 400.0;
  double currentWidth = 400;
  double defaultWidth = 400.0;
  double x = 0;
  double y = 0;
  String title = '';
  Widget body = const Placeholder();

  late Function(double, double) onWindowDragged;
  late Function() onWindowDraggedStart;
  late Function() onWindowDraggedEnd;
  late VoidCallback onCloseButtonClicked;

  ResizableWindow({required this.title, required this.body})
      : super(key: UniqueKey()) {
    currentHeight = defaultHeight;
    currentWidth = defaultWidth;
  }

  @override
  _ResizableWindowState createState() => _ResizableWindowState();
}

class _ResizableWindowState extends State<ResizableWindow> {
  final _headerSize = 50.0;
  final _borderRadius = 10.0;

  @override
  void initState() {
    print("init ${widget.title}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.y,
      left: widget.x,
      child: Container(
        decoration: BoxDecoration(
          //Here goes the same radius, u can put into a var or function
          borderRadius: BorderRadius.all(Radius.circular(_borderRadius)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x54000000),
              spreadRadius: 4,
              blurRadius: 5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(_borderRadius)),
          child: Stack(
            children: [
              Column(
                children: [_getHeader(), _getBody()],
              ),
              Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onHorizontalDragUpdate: _onHorizontalDragRight,
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
        ),
      ),
    );
  }

  _getHeader() {
    return GestureDetector(
      onPanDown: (details) {
        widget.onWindowDraggedStart();
      },
      onPanUpdate: (tapInfo) {
        setState(() {
          widget
            ..x += tapInfo.delta.dx
            ..y += tapInfo.delta.dy;
          widget.x = widget.x.clamp(0.0, double.infinity);
          widget.y = widget.y.clamp(0.0, double.infinity);
        });
        // widget.onWindowDragged(tapInfo.delta.dx, tapInfo.delta.dy);
      },
      onPanEnd: (details) {
        widget.onWindowDraggedEnd();
      },
      child: Container(
        width: widget.currentWidth,
        height: _headerSize,
        color: Colors.lightBlueAccent,
        child: Stack(
          children: [
            Positioned(
              left: 10,
              top: 0,
              bottom: 0,
              child: GestureDetector(
                  onTap: () {
                    widget.onCloseButtonClicked();
                  },
                  child: const Icon(
                    Icons.circle,
                    color: Colors.red,
                  )),
            ),
            Positioned.fill(child: Center(child: Text(widget.title))),
          ],
        ),
      ),
    );
  }

  _getBody() {
    return Container(
      width: widget.currentWidth,
      height: widget.currentHeight - _headerSize,
      color: Colors.blueGrey,
      child: widget.body,
    );
  }

  void _onHorizontalDragLeft(DragUpdateDetails details) {
    setState(() {
      widget.currentWidth -= details.delta.dx;
      if (widget.currentWidth < widget.defaultWidth) {
        widget.currentWidth = widget.defaultWidth;
      } else {
        widget.onWindowDragged(details.delta.dx, 0);
      }
    });
  }

  void _onHorizontalDragRight(DragUpdateDetails details) {
    setState(() {
      widget.currentWidth += details.delta.dx;
      if (widget.currentWidth < widget.defaultWidth) {
        widget.currentWidth = widget.defaultWidth;
      }
    });
  }

  void _onHorizontalDragBottom(DragUpdateDetails details) {
    setState(() {
      widget.currentHeight += details.delta.dy;
      if (widget.currentHeight < widget.defaultHeight) {
        widget.currentHeight = widget.defaultHeight;
      }
    });
  }

  void _onHorizontalDragTop(DragUpdateDetails details) {
    setState(() {
      widget.currentHeight -= details.delta.dy;
      if (widget.currentHeight < widget.defaultHeight) {
        widget.currentHeight = widget.defaultHeight;
      } else {
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
