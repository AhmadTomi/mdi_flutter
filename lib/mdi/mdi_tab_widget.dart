import 'package:flutter/material.dart';

import 'mdi_controller.dart';
import 'mdi_tab_controller.dart';

class MdiTabWidget extends StatefulWidget {
  final MdiController mdiController;
  const MdiTabWidget(this.mdiController,{super.key});

  @override
  State<MdiTabWidget> createState() => _MdiTabWidgetState();
}

class _MdiTabWidgetState extends State<MdiTabWidget> {

  late final MdiTabController controller;
  double _screenWidth = 0;


  @override
  void initState() {
    controller = widget.mdiController.tabMenuController;
    controller.addListener(_rebuildWidget);
    super.initState();
  }

  @override
  void dispose() {
    controller.removeListener(_rebuildWidget);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    checkScreenSize(context);
    return Container(
      color: Colors.blue.shade600,
      height: 24,
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Expanded(
            child: reorderedTab(),
          ),
          if(controller.showTabNavButton)Row(
            children: [
              _ButtonContainer(
                  enable: controller.showLeftButton,
                  onTap: (){controller.scrollLeft();},
                  borderRadius: 0,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: const Icon(Icons.arrow_back_ios,size: 16,)),
              _ButtonContainer(
                  enable: controller.showRightButton,
                  onTap: (){controller.scrollRight();},
                  borderRadius: 0,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: const Icon(Icons.arrow_forward_ios,size: 16))
            ],
          )
        ],
      ),
    );
  }

  void checkScreenSize(BuildContext context){

    bool needRebuild = false;

    final currentScreenWidth = MediaQuery.sizeOf(context).width;
    final menuLength = widget.mdiController.tabControllers.length*controller.menuWidth;
    final shouldShowNavButton = menuLength>currentScreenWidth;

    if(controller.showTabNavButton!= shouldShowNavButton){
      needRebuild = true;
    }

    if(_screenWidth != currentScreenWidth){
        _screenWidth = currentScreenWidth;
        needRebuild = true;
    }

    if(needRebuild){
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _rebuildWidget();
        controller.tabScrollCheck();
      });
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
    bool enable=true,
    void Function()? onDoubleTap,
  })
  {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Material(
        color: enable?(color ?? Colors.transparent):Theme.of(context).disabledColor,
        borderRadius: BorderRadius.circular(borderRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enable?onTap:null,
          onLongPress: enable?onLongPress:null,
          onDoubleTap: enable?onDoubleTap:null,
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

  void _rebuildWidget() {
    if(context.mounted) {
      setState(() {
      });
    }
  }

  Widget scrollTab(){
    return SingleChildScrollView(
      controller: controller.tabScrollController,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...widget.mdiController.tabControllers.map((e) => _ButtonContainer(
              color: e.hasFocus?Colors.blue.shade900:Colors.transparent,
              borderRadius: 2,
              padding: const EdgeInsets.symmetric(horizontal: 4,vertical: 2),
              width: e.hasFocus?null:controller.menuWidth,
              margin: EdgeInsets.zero,
              onTap: () => e.requestFocus(),
              child: Row(
                spacing: 2,
                children: [
                  Flexible(
                    flex: e.hasFocus?0:1,
                    child: Text(
                      e.title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(fontSize: 11,fontWeight: e.hasFocus?FontWeight.w600:null),),
                  ),
                  _ButtonContainer(
                    onTap:e.close,
                    splashColor: Colors.red,
                    padding: const EdgeInsets.all(1),
                    child: const Icon(Icons.close_rounded,size: 10,color: Colors.white,),
                  ),
                ],
              )))
        ],
      ),
    );
  }

  Widget reorderedTab(){
    final list = widget.mdiController.tabControllers;
    return ReorderableListView.builder(
        itemBuilder: (context, index) {
          final e = list[index];
          return ReorderableDragStartListener(
            key: ValueKey(index),
            enabled: true,
            index: index,
            child: _ButtonContainer(
                key: ValueKey(index),
                color: e.hasFocus?Colors.blue.shade900:Colors.transparent,
                borderRadius: 2,
                padding: const EdgeInsets.symmetric(horizontal: 4,vertical: 2),
                width: e.hasFocus?null:controller.menuWidth,
                margin: EdgeInsets.zero,
                onTap: () => e.requestFocus(),
                child: Row(
                  spacing: 2,
                  children: [
                    Flexible(
                      flex: e.hasFocus?0:1,
                      child: Text(
                        e.title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontSize: 11,fontWeight: e.hasFocus?FontWeight.w600:null),),
                    ),
                    _ButtonContainer(
                      onTap:e.close,
                      splashColor: Colors.red,
                      padding: const EdgeInsets.all(1),
                      child: const Icon(Icons.close_rounded,size: 10,color: Colors.white,),
                    ),
                  ],
                )),
          );
        },
        itemCount: list.length,
        scrollDirection: Axis.horizontal,
        buildDefaultDragHandles: false,
        scrollController: controller.tabScrollController,
        onReorder: (oldIndex, newIndex) {
          widget.mdiController.reorderTabMap(oldIndex, newIndex);
          _rebuildWidget();
        },
    );

  }
}



class _ButtonContainer extends StatelessWidget {
  final Widget child;
  final void Function()? onTap;
  final void Function()? onLongPress;
  final void Function()? onDoubleTap;
  final double? height;
  final double? width;
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? padding;
  final BoxBorder? border;
  final double borderRadius;
  final BoxConstraints? constraints;
  final Color? color;
  final Color? splashColor;
  final EdgeInsetsGeometry? margin;
  final bool enable;

  const _ButtonContainer({
    super.key,
    required this.child,
    this.onTap,
    this.height,
    this.width,
    this.alignment,
    this.padding,
    this.border,
    this.onLongPress,
    this.borderRadius = 4,
    this.constraints,
    this.color,
    this.splashColor,
    this.margin,
    this.enable = true,
    this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Use the custom splashColor or default to the theme's primary color with alpha
    final effectiveSplashColor = splashColor ?? theme.primaryColor.withOpacity(0.2);

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Container(
        height: height,
        width: width,
        constraints: constraints,
        // The Container handles all decoration and clipping
        decoration: BoxDecoration(
          color: enable ? (color ?? Colors.transparent) : theme.disabledColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: border,
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          // Material is transparent; decoration is handled by the Container
          color: Colors.transparent,
          child: InkWell(
            onTap: enable ? onTap : null,
            onLongPress: enable ? onLongPress : null,
            onDoubleTap: enable ? onDoubleTap : null,
            splashColor: effectiveSplashColor,
            hoverColor: effectiveSplashColor.withOpacity(0.1),
            highlightColor: effectiveSplashColor.withOpacity(0.15),
            // We remove 'splashFactory: NoSplash.splashFactory' to enable the ripple
            child: Container(
              // This inner Container handles layout
              padding: padding,
              alignment: alignment,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
