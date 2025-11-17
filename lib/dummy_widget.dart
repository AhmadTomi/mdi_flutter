import 'package:flutter/material.dart';

import 'mdi/resizable_window/resizable_window.dart';

class DummyWidget extends StatefulWidget {
  const DummyWidget({super.key,});

  @override
  State<DummyWidget> createState() => _DummyWidgetState();
}

class _DummyWidgetState extends State<DummyWidget> {

  FocusNode focusNode = FocusNode();

  bool isFocused = false;

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    final ctrl = ResizableWindowProvider.of(context);

    if(ctrl!=null){
      if(ctrl.hasFocus != isFocused){
        isFocused = ctrl.hasFocus;
        if(isFocused){
          focusNode.requestFocus();
        }
      }
    }



    return Column(
      children: [
        ctrl?.dragWidget(
            child: Container(
              color: Colors.blue.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              height: 30,
              alignment: Alignment.center,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "${ctrl.tag}",
                      style: const TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 16,
                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                    onPressed: () => ctrl.close(), // Close button
                    icon: const Icon(Icons.close, color: Colors.white),
                  )
                ],
              ),
            )
        )??const SizedBox(),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.topLeft,
            width: double.infinity, // Ensure it fills the space
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '''
                      ${ctrl?.tag} Lorem Ipsum is simply dummy text...
                                  ''',
                    style: const TextStyle(color: Colors.white),
                  ),
                  TextFormField(
                    focusNode: focusNode,
                  ),
                  // If you need the controller (e.g., for a button):
                  TextButton(
                    onPressed: () {
                      // This is how you access the controller now!
                      ctrl?.close();
                    },
                    child: const Text("Close from inside"),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
