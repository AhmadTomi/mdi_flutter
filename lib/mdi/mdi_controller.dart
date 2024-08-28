import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_app_mdi/mdi/parameter_window.dart';

import 'resizable_window.dart';


class MdiController{

  MdiController(){
    streamController.add(_windows);
  }



  Size defaultScreenSize = const Size(0, 0);
  Size screenSize = const Size(0, 0);

  final StreamController<List<ResizableWindow>> streamController = StreamController<List<ResizableWindow>>.broadcast();

  final List<ResizableWindow> _windows = List.empty(growable: true);

  final Map<Key, ParameterWindow> _windowParameters = {};

  void _onUpdate(){
    streamController.add(List.from(_windows));
  }

  onDispose(){
    streamController.close();
  }


  List<ResizableWindow> get windows => _windows;


  void addWindow(String title,Widget child){
    _createNewWindowedApp(title,child);
  }


  void addCalculatorApp(){

    _createNewWindowedApp("Calculator",const Placeholder());

  }
  void _createNewWindowedApp(String title,Widget app){

    ResizableWindow? resizableWindow;

    Key key= UniqueKey();

    ParameterWindow parameter = ParameterWindow(
        id: 'id',
        title: 'title',
        x: Random().nextDouble() * 200,
        y: Random().nextDouble() * 200,

    );


    resizableWindow = ResizableWindow(
      key: key,
      parameter: parameter,
      body: Column(
        children: [
          Container(
            height: 36,
            color: Colors.lightBlueAccent,
            child: Stack(
              children: [
                Positioned(
                  left: 10,
                  top: 0,
                  bottom: 0,
                  child: GestureDetector(
                      onTap: () {
                        if(resizableWindow!=null){
                          _windows.remove(resizableWindow);
                          _onUpdate();
                        }
                      },
                      child: const Icon(
                        Icons.circle,
                        color: Colors.red,
                      )),
                ),
                Positioned.fill(child: Center(child: Text("$title $key"))),
              ],
            ),
          ),
          Expanded(child: app)
        ],
      ),
      onWindowDraggedStart: () {
        if(_windows.last.key!=key && resizableWindow!=null){
          _windows.remove(resizableWindow);
          _windows.add(resizableWindow);
          _onUpdate();
        }
      },
      onWindowDragged: (dx,dy){
      },
      onWindowDraggedEnd: (x,y){
        _windowParameters[key]?.updateParameter(
          posX: x,
          posY: y,
        );
        final maxSize = getCornerPosition();
        final newSize = Size(
            max(maxSize.width, defaultScreenSize.width),
            max(maxSize.height, defaultScreenSize.height)
        );
        if (newSize != screenSize) {
          screenSize = newSize;
          _onUpdate();
        }
      },
      onWindowResized: (x,y,width, height) {
        _windowParameters[key]?.updateParameter(
            posX:x,
            posY:y,
            height: height,
            width: width
        );

        final maxSize = getCornerPosition();
        final newSize = Size(
            max(maxSize.width, defaultScreenSize.width),
            max(maxSize.height, defaultScreenSize.height)
        );
        if (newSize != screenSize) {
          screenSize = newSize;
          _onUpdate();
        }

      },
      onCloseButtonClicked: (){
        if(resizableWindow!=null){
          _windows.remove(resizableWindow);
          _onUpdate();
        }
      },
      windowBuilder: (context,child) {
        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          clipBehavior: Clip.antiAlias,
          child: child,
        );
      },

    );

    //Add Window to List
    _windows.add(resizableWindow);
    _windowParameters[key] = parameter;

    // Update Widgets after adding the new App
    _onUpdate();

  }

  bool isTopWindow(Key key) => _windows.last.key == key;

  Size getCornerPosition(){
    double x = 0;
    double y = 0;

    _windowParameters.forEach((key, value) {
      x = max(value.cornerX,x);
      y = max(value.cornerY,y);
    });
    return Size(x,y);
  }


}
