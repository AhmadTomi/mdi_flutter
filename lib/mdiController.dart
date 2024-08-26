import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'resizableWindow.dart';

class MdiController{

  MdiController(){
    streamController.add(_windows);
  }



  Size defaultScreenSize = const Size(0, 0);
  Size screenSize = const Size(0, 0);

  final StreamController<List<ResizableWindow>> streamController = StreamController<List<ResizableWindow>>.broadcast();

  final List<ResizableWindow> _windows = List.empty(growable: true);

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


    ResizableWindow resizableWindow = ResizableWindow(title: title,body: app,);


    //Set initial position
    var rng = Random();
    resizableWindow.x = rng.nextDouble() * 200;
    resizableWindow.y = rng.nextDouble() * 200;


    resizableWindow.onWindowDraggedStart = (){

      if(_windows.last!=resizableWindow){
        _windows.remove(resizableWindow);
        _windows.add(resizableWindow);
        _onUpdate();
      }
    };

    //Init onWindowDragged
    resizableWindow.onWindowDragged = (dx,dy){

      resizableWindow.x += dx;
      resizableWindow.y += dy;

      //Limit drag on top and left screen

      //Put on top of stack




    };

    resizableWindow.onWindowDraggedEnd = () {
      final newSize = Size(
          max(maxHorizontalPosition, defaultScreenSize.width),
          max(maxVerticalPosition, defaultScreenSize.height)
      );

      if (newSize != screenSize) {
        screenSize = newSize;
        _onUpdate();
      }
    };

    //Init onCloseButtonClicked
    resizableWindow.onCloseButtonClicked = (){
      _windows.remove(resizableWindow);
      _onUpdate();
    };


    //Add Window to List
    _windows.add(resizableWindow);

    // Update Widgets after adding the new App
    _onUpdate();

  }

  double get maxHorizontalPosition {
    double result = 0;
    if (windows.isNotEmpty) {
      result = windows
          .map((element) => element.x + element.currentWidth)
          .reduce((a, b) => a > b ? a : b);
    }
    return result;
  }

  double get maxVerticalPosition {
    double result = 0;
    if (windows.isNotEmpty) {
      return windows
          .map((element) => element.y + element.currentHeight)
          .reduce((a, b) => a > b ? a : b);
    }
    return result;
  }


}
