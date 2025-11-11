import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_app_mdi/mdi/mdi_manager/mdi_controller.dart';
import 'package:flutter_app_mdi/mdi/mdi_tab/mdi_tab_widget.dart';

import '../mdi_style.dart';

class MdiManager extends StatefulWidget {
  final MdiController controller;
  final MdiStyleConfiguration? style;
  const MdiManager({super.key,required this.controller, this.style});
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
    return MdiStyleProvider(
      style: widget.style ?? MdiStyleConfiguration(),
      child: FocusScope(
        onKeyEvent: (node, event) {
          final isHandled = widget.controller.onKeyEvent(event);
          return (isHandled)? KeyEventResult.handled:KeyEventResult.ignored;
        },
        onFocusChange: (value) {
          widget.controller.hasFocus = value;
          _rebuildWidget();
        },
        child: Builder(builder: (context) => ColoredBox(
          color: MdiStyleProvider.of(context).mdiBackgroundColor,
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
                                              ...widget.controller.windowWidgets,
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
        )),
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
}


