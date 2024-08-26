import 'package:flutter/material.dart';

import 'mdiController.dart';
import 'resizableWindow.dart';

class MdiManager extends StatefulWidget {
  final void Function(MdiController controller) onMdiControllerCreated;
  const MdiManager({super.key, required this.onMdiControllerCreated});

  @override
  State<MdiManager> createState() => _MdiManagerState();
}

class _MdiManagerState extends State<MdiManager> {

  late final MdiController mdiController;

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
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SizedBox(
                  width: (mdiController.maxHorizontalPosition>constraints.maxWidth)?mdiController.maxHorizontalPosition:constraints.maxWidth,
                  height: (mdiController.maxVerticalPosition>constraints.maxHeight)?mdiController.maxVerticalPosition:constraints.maxHeight,
                  child: Stack(
                      children: snapshot.data??[]
                  ),
                ),
              ),
            );
          }
      );
    });
  }
}

