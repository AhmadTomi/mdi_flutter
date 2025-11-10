import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_app_mdi/mdi/mdi_controller.dart';
import 'package:flutter_app_mdi/mdi/mdi_tab_widget.dart';
import 'package:flutter_app_mdi/mdi/resizable_window.dart';

class MdiManager extends StatefulWidget {
  final MdiController controller;
  const MdiManager({super.key,required this.controller});
  @override
  State<MdiManager> createState() => _MdiManagerState();
}

class _MdiManagerState extends State<MdiManager> {

  @override
  void initState() {
    widget.controller.init();
    widget.controller.addListener(_rebuildWidget);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuildWidget);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      onKeyEvent: (node, event) {

        final isHandled = widget.controller.onKeyEvent(event);
        return (isHandled)? KeyEventResult.handled:KeyEventResult.ignored;
      },
      onFocusChange: (value) {
        widget.controller.hasFocus = value;
        _rebuildWidget();
      },
      child: Column(
        children: [
          MdiTabWidget(widget.controller),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  updateScreenSize(constraints.biggest);
                  return ScrollConfiguration(
                    behavior: const ScrollBehavior().copyWith(
                        dragDevices: {
                          PointerDeviceKind.touch,
                          PointerDeviceKind.trackpad,
                        },
                        scrollbars: false
                    ),
                    child: Stack(
                      children: [
                        SizedBox.expand(
                          child: Scrollbar(
                            trackVisibility: false,
                            thumbVisibility: true,
                            interactive: true,
                            thickness: 4,
                            controller: widget.controller.horizontalController,
                            child: SingleChildScrollView(
                              controller: widget.controller.horizontalController,
                              scrollDirection: Axis.horizontal,
                              hitTestBehavior: HitTestBehavior.opaque,
                              child: SingleChildScrollView(
                                controller: widget.controller.verticalController,
                                hitTestBehavior: HitTestBehavior.opaque,
                                scrollDirection: Axis.vertical,
                                child: SizedBox.fromSize(
                                  size: widget.controller.mdiSize,
                                  child: RepaintBoundary(
                                    child: Stack(
                                      children: [
                                        ...widget.controller.controllers.map((controller) {
                                          return ResizableWindow(
                                            key: ValueKey(controller.parameter.tag),
                                            controller: controller,

                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: Scrollbar(
                            controller: widget.controller.verticalScrollBarController,
                            trackVisibility: false,
                            thumbVisibility: true,
                            interactive: true,
                            thickness: 4,
                            child: SingleChildScrollView(
                                controller: widget.controller.verticalScrollBarController,
                                hitTestBehavior: HitTestBehavior.opaque,
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: Container(
                                    width: 20,
                                    color: Colors.transparent,
                                    height: widget.controller.mdiSize.height.clamp(constraints.maxHeight, double.infinity)
                                )),
                          ),
                        )
                      ],
                    ),
                  );
                }
              ),
            ),
          ),
        ],
      ),
    );
  }

  void updateScreenSize(Size size){
    final height = size.height;
    final width = size.width;

    Size newScreenSize = Size(width,height);

    if(widget.controller.mdiSize==Size.zero){
      widget.controller.mdiSize = newScreenSize;
    }


    if(widget.controller.screenSize!=newScreenSize){
      widget.controller.screenSize = newScreenSize;
      widget.controller.calculateUpdateScreenSize();
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        widget.controller.tabMenuController.tabScrollCheck();
        _rebuildWidget();
      });
    }


  }

  void _rebuildWidget() {
    if(context.mounted) {
      setState(() {});
    }
  }

  Widget buttonContainer({
    Key? key,
    required Widget child,
    void Function()? onTap,
    double? height,
    double? width,
    AlignmentGeometry? alignment,
    EdgeInsetsGeometry? padding,
    BoxBorder? border,
    void Function()? onLongPress,
    double borderRadius = 4,
    BoxConstraints? constraints,
    Color? color,
    Color? splashColor,
    EdgeInsetsGeometry? margin,
    void Function()? onDoubleTap,
  }) {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Material(
        color: color ?? Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          onDoubleTap: onDoubleTap,
          splashColor: splashColor ?? Theme.of(context).primaryColor.withValues(alpha:0.5),
          hoverColor: splashColor ?? Theme.of(context).primaryColor.withValues(alpha:0.2),
          highlightColor: splashColor ?? Theme.of(context).primaryColor.withValues(alpha:0.4),
          splashFactory: NoSplash.splashFactory,
          child: Container(
            padding: padding,
            alignment: alignment,
            constraints: constraints,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            width: width,
            height: height,
            clipBehavior: Clip.antiAlias,
            child: child,
          ),
        ),
      ),
    );
  }
}
