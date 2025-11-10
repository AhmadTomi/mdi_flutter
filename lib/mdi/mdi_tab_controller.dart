import 'package:flutter/material.dart';

class MdiTabController extends ChangeNotifier{

  final ScrollController tabScrollController = ScrollController();

  bool _showLeftButton = false;
  bool _showRightButton = false;
  bool _showNavTabButton = false;
  final double _scrollAmount = 80.0;
  final double menuWidth = 60.0;

  bool get showLeftButton => _showLeftButton;
  bool get showRightButton => _showRightButton;
  bool get showTabNavButton => _showNavTabButton;

  void init(){
    tabScrollController.addListener(_scrollListener);
  }

  // CODE TAB WIDGET
  void _scrollListener() {
    tabScrollCheck();
    notifyListeners();
  }
  void tabScrollCheck(){
    if (!tabScrollController.hasClients) {
      _showNavTabButton = false;
      return;
    }

    double maxScroll = tabScrollController.position.maxScrollExtent;
    double currentScroll = tabScrollController.position.pixels;
    double minScroll = tabScrollController.position.minScrollExtent;

    bool canScrollLeft = currentScroll > minScroll;
    bool canScrollRight = currentScroll < maxScroll;

    // Check if the state actually changed before notifying listeners
    if (canScrollLeft != _showLeftButton || canScrollRight != _showRightButton) {
      _showLeftButton = canScrollLeft;
      _showRightButton = canScrollRight;
    }

    _showNavTabButton = (canScrollRight||canScrollLeft);
  }

  // The scroll functions are moved here
  void scrollLeft() {
    double newOffset = (tabScrollController.offset - _scrollAmount).clamp(
      tabScrollController.position.minScrollExtent,
      tabScrollController.position.maxScrollExtent,
    );
    tabScrollController.animateTo(
      newOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void scrollRight() {
    double newOffset = (tabScrollController.offset + _scrollAmount).clamp(
      tabScrollController.position.minScrollExtent,
      tabScrollController.position.maxScrollExtent,
    );
    tabScrollController.animateTo(
      newOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }







}