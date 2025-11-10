import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_app_mdi/mdi/parameter_window.dart';
import 'package:flutter_app_mdi/mdi/resizable_window_controller.dart';

class ResizableWindow extends StatefulWidget {
  final ResizeableWindowController controller;

  const ResizableWindow({super.key, required this.controller,});

  @override
  State<ResizableWindow> createState() => ResizableWindowState();
}

class ResizableWindowState extends State<ResizableWindow> {


  Size lastPosition = const Size(0, 0);
  Size lastSize = const Size(400, 400);



  int lastTap = 0;
  int consecutiveTaps = 1;


  late final ResizeableWindowController controller;

  @override
  void initState() {

    controller = widget.controller;
    controller.focusScopeNode = FocusScopeNode();

    controller.addListener(_rebuildWidget);
    super.initState();
  }

  @override
  void dispose() {
    controller.removeListener(_rebuildWidget);
    controller.focusScopeNode?.dispose();
    controller.focusScopeNode = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: controller.y,
        left: controller.x,
        child: Padding(
          padding: EdgeInsets.all(controller.widgetPadding),
          child: _windowBuilder(1),
        )
    );
  }



  void _rebuildWidget() {
    if(context.mounted) {
      setState(() {
      });
    }
  }

  void rebuild() {
    setState(() {
    });
  }

  Widget dragWidget({required Widget child, bool canDoubleClick = true}){
    return GestureDetector(
      supportedDevices: const {
        PointerDeviceKind.mouse,
      },
      onTap: () {
        /*if(canDoubleClick){
          int now = DateTime.now().millisecondsSinceEpoch;
          if (now - lastTap < 300) {
            consecutiveTaps++;
            if (consecutiveTaps >= 2) {
              setState(() {
                widget.onMaximize((width, height) {
                  if(controller.currentWidth>=(width-controller.widgetPadding) && controller.currentHeight>=(height-controller.widgetPadding)){
                    controller.x = lastPosition.width;
                    controller.y = lastPosition.height;
                    controller.currentWidth = lastSize.width;
                    controller.currentHeight = lastSize.height;

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
                widget.onWindowResized(controller.x,controller.y,controller.currentWidth,controller.currentHeight);
              });
            }
          }
          consecutiveTaps = 1;
          lastTap = now;
        }*/
        controller.requestFocus();
      },
      onPanDown: (details) {
        controller.requestFocus();
        // widget.onWindowDraggedStart();
      },
      onPanUpdate: (tapInfo) {
        setState(() {
          controller.x += tapInfo.delta.dx;
          controller.y += tapInfo.delta.dy;
          controller.x = controller.x.clamp(0.0, double.infinity);
          controller.y = controller.y.clamp(0.0, double.infinity);
        });
        // widget.onWindowDragged(tapInfo.delta.dx, tapInfo.delta.dy);
      },
      onPanEnd: (details) {
        controller.onWindowDragEnd();
        controller.positionChangeAction();
        // widget.onWindowDraggedEnd(controller.x,controller.y);
      },
      child: MouseRegion(
          cursor: SystemMouseCursors.click,
          opaque: true,
          hitTestBehavior: HitTestBehavior.translucent,
          child: child),
    );
  }

  Widget _windowBuilder(double gap){
    return Padding(
      padding: EdgeInsets.all(controller.isMaximized?0:gap),
      child: FocusScope(
        node: controller.focusScopeNode,
        onFocusChange: (value) {
          _rebuildWidget();
          controller.onFocusChange?.call(value);
        },
        child: GestureDetector(
          onTap: (controller.hasFocus)?null:controller.requestFocus,
          child: Container(
            decoration: ShapeDecoration(
              color: Color(0xFF1b1b1b),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: controller.isMaximized?Colors.transparent:controller.hasFocus?Colors.yellow: Colors.red, width: 1.2,strokeAlign: 0),
                borderRadius: BorderRadius.circular(controller.isMaximized?0:4),
              ),
            ),
            /*decoration: BoxDecoration(
              color: const Color(0xFF1b1b1b),
              borderRadius: BorderRadius.circular(12),
              shape: RoundedSuperellipseBorder(
                borderRadius: BorderRadius.circular(28.0),
              ), // S
              // border: Border.all(color:controller.hasFocus? Colors.green:Colors.yellow,strokeAlign: BorderSide.strokeAlignCenter,width: 1.2),
            ),*/
            width: controller.currentWidth-(controller.isMaximized?0:(2*gap)),
            height: controller.currentHeight-(controller.isMaximized?0:(2*gap)),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: ClipRRect(
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadiusGeometry.circular(controller.isMaximized?0:3),
              child: SizedBox(
                height: controller.currentHeight+1,
                child: Stack(
                  children: [
                    // ScaleWidget(minWidth: ParameterWindow.defaultMinWidth*2, maxScale: LocalStorage.userPreferencesDB.widgetScaleLimit, child: widget.body(context)),
                    SizedBox.expand(
                      child: Column(
                        children: [
                          // dragWidget(
                          //   child: widget.header?.call(context)??const SizedBox(),
                          // ),
                          Expanded(child: widget.controller.child(widget.controller)),
                        ],
                      ),
                    ),
                    IgnorePointer(
                      ignoring: true,
                      child: ColoredBox(
                        color: Colors.blue.withValues(alpha:(controller.hasFocus)?0.0: 0.6),
                          child: const SizedBox.expand()),
                    ),
                    // widget.body(context),
                    Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: IgnorePointer(
                          ignoring: controller.isMaximized,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onHorizontalDragStart: (details) => controller.requestFocus(),
                            onHorizontalDragUpdate: (details) {
                              controller.onHorizontalDragRight(details);
                              _rebuildWidget();

                            },
                            onHorizontalDragEnd: (details) {
                              controller.onHorizontalRightDragEnd(details);
                              _rebuildWidget();
                              controller.positionChangeAction();
                              // widget.onWindowResized(controller.x,controller.y,controller.currentWidth,controller.currentHeight);
                            },
                            child: const MouseRegion(
                              cursor: SystemMouseCursors.resizeLeftRight,
                              opaque: true,
                              child: SizedBox(
                                width: 4,
                              ),
                            ),
                          ),
                        )),
                    Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: IgnorePointer(
                          ignoring: controller.isMaximized,
                          child: GestureDetector(
                            onHorizontalDragStart: (details) => controller.requestFocus(),
                            onHorizontalDragUpdate: (details) {
                              controller.onHorizontalDragLeft(details);
                              _rebuildWidget();
                            },
                            onHorizontalDragEnd: (details) {
                              controller.onHorizontalLeftDragEnd(details);
                              _rebuildWidget();
                              // widget.onWindowResized(controller.x,controller.y,controller.currentWidth,controller.currentHeight);
                            },
                            child: const MouseRegion(
                              cursor: SystemMouseCursors.resizeLeftRight,
                              opaque: true,
                              child: SizedBox(
                                width: 4,
                              ),
                            ),
                          ),
                        )),
                    Positioned(
                        left: 0,
                        top: 0,
                        right: 0,
                        child: IgnorePointer(
                          ignoring: controller.isMaximized,
                          child: GestureDetector(
                            onVerticalDragStart: (details) => controller.requestFocus(),
                            onVerticalDragUpdate: (details) {
                              controller.onHorizontalDragTop(details);
                              _rebuildWidget();
                            },
                            onVerticalDragEnd: (details) {
                              controller.onVerticalDragTopEnd(details);
                              _rebuildWidget();
                              // widget.onWindowResized(controller.x,controller.y,controller.currentWidth,controller.currentHeight);
                            },
                            child: const MouseRegion(
                              cursor: SystemMouseCursors.resizeUpDown,
                              opaque: true,
                              child: SizedBox(
                                height: 4,
                              ),
                            ),
                          ),
                        )),
                    Positioned(
                        left: 0,
                        bottom: 0,
                        right: 0,
                        child: IgnorePointer(
                          ignoring: controller.isMaximized,
                          child: GestureDetector(
                            onVerticalDragStart: (details) => controller.requestFocus(),
                            onVerticalDragUpdate: (details) {
                              controller.onHorizontalDragBottom(details);
                              _rebuildWidget();
                            },
                            onVerticalDragEnd: (details) {
                              controller.onVerticalDragBottomEnd(details);
                              _rebuildWidget();
                              controller.positionChangeAction();
                              // widget.onWindowResized(controller.x,controller.y,controller.currentWidth,controller.currentHeight);
                            },
                            child: const MouseRegion(
                              cursor: SystemMouseCursors.resizeUpDown,
                              opaque: true,
                              child: SizedBox(
                                height: 4,
                              ),
                            ),
                          ),
                        )),
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: IgnorePointer(
                          ignoring: controller.isMaximized,
                          child: GestureDetector(
                            onPanStart: (details) => controller.requestFocus(),
                            onPanUpdate: (details) {
                              controller.onHorizontalDragBottomRight(details);
                              _rebuildWidget();
                            },
                            onPanEnd: (details) {
                              controller.positionChangeAction();
                              // widget.onWindowResized(controller.x,controller.y,controller.currentWidth,controller.currentHeight);
                            },
                            child: const MouseRegion(
                              cursor: SystemMouseCursors.resizeUpLeftDownRight,
                              opaque: true,
                              child: SizedBox.square(
                                dimension: 12,
                              ),
                            ),
                          ),
                        )),
                    Positioned(
                        bottom: 0,
                        left: 0,
                        child: IgnorePointer(
                          ignoring: controller.isMaximized,
                          child: GestureDetector(
                            onPanStart: (details) => controller.requestFocus(),
                            onPanUpdate: (details) {
                              controller.onHorizontalDragBottomLeft(details);
                              _rebuildWidget();
                            },
                            onPanEnd: (details) {
                              controller.positionChangeAction();
                              // widget.onWindowResized(controller.x,controller.y,controller.currentWidth,controller.currentHeight);
                            },
                            child: const MouseRegion(
                              cursor: SystemMouseCursors.resizeUpRightDownLeft,
                              opaque: true,
                              child: SizedBox.square(
                                dimension: 12,
                              ),
                            ),
                          ),
                        )),
                    Positioned(
                        top: 0,
                        right: 0,
                        child: IgnorePointer(
                          ignoring: controller.isMaximized,
                          child: GestureDetector(
                            onPanStart: (details) => controller.requestFocus(),
                            onPanUpdate: (details) {
                              controller.onHorizontalDragTopRight(details);
                              _rebuildWidget();
                            },
                            onPanEnd: (details) {
                              controller.positionChangeAction();
                              // widget.onWindowResized(controller.x,controller.y,controller.currentWidth,controller.currentHeight);
                            },
                            child: const MouseRegion(
                              cursor: SystemMouseCursors.resizeUpRightDownLeft,
                              opaque: true,
                              child: SizedBox.square(
                                dimension: 12,
                              ),
                            ),
                          ),
                        )),
                    Positioned(
                        left: 0,
                        top: 0,
                        child: IgnorePointer(
                          ignoring: controller.isMaximized,
                          child: GestureDetector(
                            onPanStart: (details) => controller.requestFocus(),
                            onPanUpdate: (details) {
                              controller.onHorizontalDragTopLeft(details);
                              _rebuildWidget();
                            },
                            onPanEnd: (details) {
                              // widget.onWindowResized(controller.x,controller.y,controller.currentWidth,controller.currentHeight);
                            },
                            child: const MouseRegion(
                              cursor: SystemMouseCursors.resizeUpLeftDownRight,
                              opaque: true,
                              child: SizedBox.square(
                                dimension: 12,
                              ),
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}