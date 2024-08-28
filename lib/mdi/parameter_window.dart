import 'package:flutter/material.dart';

class ParameterWindow {
  // Private fields
  final String _id;
  final String _title;
  String _argument;

  // Public fields
  final double minWidth;
  final double minHeight;
  double currentWidth;
  double currentHeight;
  double x;
  double y;

  // Static constants
  static const double defaultWidth = 382.0;
  static const double defaultHeight = 499.0;
  static const double defaultMinWidth = 382.0;
  static const double defaultMinHeight = 250.0;

  // Constructor with required parameters and default values
  ParameterWindow({
    required String id,
    required String title,
    String argument = '',
    double? minHeight,
    double? minWidth,
    this.currentWidth = defaultWidth,
    this.currentHeight = defaultHeight,
    this.x = 0.0,
    this.y = 0.0,
  })  : _id = id,
        _title = title,
        _argument = argument,
        minHeight = minHeight ?? defaultMinHeight,
        minWidth = minWidth ?? defaultMinWidth;

  // Getters for private fields
  String? get id => _id;
  String get title => _title;
  String get argument => _argument;
  void setArgument(String args)=>_argument = args;

  // Method to get width scale
  static int getWidthScale(double width) {
    int result = (width + 6) ~/ defaultWidth;
    return result < 1 ? 1 : result;
  }

  // Method to get height scale
  static int getHeightScale(double height) {
    int result = (height + 6) ~/ defaultHeight;
    return result < 1 ? 1 : result;
  }

  void updateParameter({
    String? argument,
    double? width,
    double? height,
    double? posX,
    double? posY,
  }){
    x = posX ?? x;
    y = posY ?? y;
    currentWidth = width ?? currentWidth;
    currentHeight = height ?? currentHeight;

  }

  double get cornerX => x+currentWidth;
  double get cornerY => y+currentHeight;

  void debugLog(){
   debugPrint("id:$_id");
   debugPrint("title:$_title");
   debugPrint("Position: $x,$y");
   debugPrint("CurrentSize:$currentWidth,$currentHeight");
  }

  // CopyWith method
  ParameterWindow copyWith({
    String? id,
    String? title,
    String? argument,
    double? minHeight,
    double? minWidth,
    double? currentWidth,
    double? currentHeight,
    double? x,
    double? y,
  }) {
    return ParameterWindow(
      id: id ?? _id,
      title: title ?? _title,
      argument: argument ?? _argument,
      minHeight: minHeight ?? this.minHeight,
      minWidth: minWidth ?? this.minWidth,
      currentWidth: currentWidth ?? this.currentWidth,
      currentHeight: currentHeight ?? this.currentHeight,
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }
}
