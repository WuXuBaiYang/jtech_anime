import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'view.dart';

/*
* 焦点容器子元素
* @author wuxubaiyang
* @Time 2023/10/26 14:02
*/
class FocusTile extends StatefulWidget {
  // 获取焦点构造器
  final FocusBuilder builder;

  // 子元素
  final Widget? child;

  // 确认回调
  final VoidCallback? onConfirm;

  // 菜单回调
  final VoidCallback? onMenu;

  // 自动获取焦点
  final bool autofocus;

  const FocusTile({
    super.key,
    required this.builder,
    this.child,
    this.onMenu,
    this.onConfirm,
    this.autofocus = false,
  });

  @override
  State<StatefulWidget> createState() => _FocusTileState();
}

/*
* 焦点容器子元素-状态
* @author wuxubaiyang
* @Time 2023/10/26 14:03
*/
class _FocusTileState extends State<FocusTile> {
  // 当前元素焦点
  final focusNode = FocusNode();

  // 支持按键输入
  late final keyEventMap =
      <LogicalKeyboardKey, KeyEventResult Function(FocusNode node)>{
    // 确定事件
    LogicalKeyboardKey.enter: (FocusNode node) {
      widget.onConfirm?.call();
      return KeyEventResult.handled;
    },
    // 菜单事件
    LogicalKeyboardKey.tab: (FocusNode node) {
      widget.onMenu?.call();
      return KeyEventResult.handled;
    },
  };

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      autofocus: widget.autofocus,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        if (keyEventMap.containsKey(event.logicalKey)) {
          return keyEventMap[event.logicalKey]!(node);
        }
        return KeyEventResult.ignored;
      },
      onFocusChange: (_) => setState(() {}),
      child: widget.builder(
        context,
        focusNode,
        widget.child,
      ),
    );
  }
}
