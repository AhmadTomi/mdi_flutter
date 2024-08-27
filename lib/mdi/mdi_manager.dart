import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'mdi_controller.dart';
import 'resizable_window.dart';

class MdiManager extends StatefulWidget {
  final void Function(MdiController controller) onMdiControllerCreated;
  const MdiManager({super.key, required this.onMdiControllerCreated});

  @override
  State<MdiManager> createState() => _MdiManagerState();
}

class _MdiManagerState extends State<MdiManager> {

  late final MdiController mdiController;

  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  @override
  void initState() {
    mdiController = MdiController();
    widget.onMdiControllerCreated(mdiController);
    super.initState();
  }

  @override
  void dispose() {
    mdiController.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      mdiController.defaultScreenSize = constraints.biggest;
      return StreamBuilder<List<ResizableWindow>>(
          stream: mdiController.streamController.stream,
          builder: (context, snapshot) {
            print("Build Manager");
            return Scrollbar(
              controller: _horizontalController,
              trackVisibility: true,
              thumbVisibility: true,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _horizontalController,
                child: Scrollbar(
                  controller: _verticalController,
                  trackVisibility: true,
                  thumbVisibility: true,
                  scrollbarOrientation: ScrollbarOrientation.left,
                  child: SingleChildScrollView(
                    controller: _verticalController,
                    scrollDirection: Axis.vertical,
                    child: SizedBox(
                      width: mdiController.screenSize.width.clamp(constraints.maxWidth, double.infinity),
                      height: mdiController.screenSize.height.clamp(constraints.maxHeight, double.infinity),
                      child: Stack(
                          children: snapshot.data??[]
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
      );
    });
  }
}

