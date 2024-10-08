import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_mdi/mdi/parameter_window.dart';

import 'resizable_window.dart';


class MdiController{

  MdiController(){
    streamController.add(_windows);
    HardwareKeyboard.instance.addHandler(_keyHandler);
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
    HardwareKeyboard.instance.removeHandler(_keyHandler);
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

    // Key key= UniqueKey();
    final GlobalKey<ResizableWindowState> key = GlobalKey();

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
                        closeWindow(key);
                      },
                      child: const Icon(
                        Icons.circle,
                        color: Colors.red,
                      )),
                ),
                Positioned.fill(child: Center(child: Text("$title ${key.hashCode}"))),
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

          rebuildWindow(_windows.length-2);
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
        final maxSize = _getCornerPosition();
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

        final maxSize = _getCornerPosition();
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
        closeWindow(key);
      },
      windowBuilder: (context,child) {
        return Container(
          decoration: BoxDecoration(
          border: Border.all(color: (key==_windows.last.key)? Colors.red : Colors.transparent,strokeAlign: BorderSide.strokeAlignOutside,width: 1.5),
            borderRadius: const BorderRadius.all(Radius.circular(4)),
          ),
          clipBehavior: Clip.antiAlias,
          child: child,
        );
      },

    );

    //Add Window to List


    _windows.add(resizableWindow);
    _windowParameters[key] = parameter;

    rebuildWindow(_windows.length-2);

    // Update Widgets after adding the new App
    _onUpdate();

  }

  bool isTopWindow(Key key) => _windows.last.key == key;

  Size _getCornerPosition(){
    double x = 0;
    double y = 0;

    _windowParameters.forEach((key, value) {
      x = max(value.cornerX,x);
      y = max(value.cornerY,y);
    });
    return Size(x,y);
  }

  void closeWindow(Key? key){
    if (key==null) return;
    var window = _windows.cast<ResizableWindow?>().firstWhere((window) => window?.key == key, orElse: () => null);

    if(window!=null){
      _windows.remove(window);
      rebuildWindow(_windows.length-1);
      _windowParameters.remove(key);

      _onUpdate();
    }
  }

  void rebuildWindow(int index) {
    if (index >= 0 && index < _windows.length) {
      (_windows[index].key as GlobalKey<ResizableWindowState>?)?.currentState?.rebuild();
    }
  }

  bool _keyHandler(KeyEvent event){
    if(event is KeyDownEvent ){
      if(event.logicalKey == LogicalKeyboardKey.escape){
        if(_windows.isNotEmpty){
          closeWindow(_windows.last.key);
        }

      }
      if(HardwareKeyboard.instance.isControlPressed){
        if(event.logicalKey == LogicalKeyboardKey.arrowRight){
          if(_windows.length>1){
            ResizableWindow window = _windows.removeAt(0);
            _windows.add(window);
            _onUpdate();
            rebuildWindow(_windows.length-2);
            rebuildWindow(_windows.length-1);
          }
          return true;
        }
        if(event.logicalKey == LogicalKeyboardKey.arrowLeft){
          if(_windows.length>1){
            ResizableWindow window = _windows.removeLast();
            _windows.insert(0, window);
            _onUpdate();
            rebuildWindow(0);
            rebuildWindow(_windows.length-1);
          }
          return true;
        }
      }
    }
    return false;
  }

}
