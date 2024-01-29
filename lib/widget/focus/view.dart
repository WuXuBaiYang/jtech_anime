import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 焦点元素构造器
typedef FocusBuilder = Widget Function(
    BuildContext context, FocusNode node, Widget? child);

/*
* 焦点控制容器
* @author wuxubaiyang
* @Time 2023/10/26 13:48
*/
class FocusView extends StatefulWidget {
  // 主体构建器
  final FocusBuilder builder;

  // 主体组件
  final Widget? child;

  // 是否主轴布局
  final bool isMainAxis;

  // 顶栏容器
  final FocusViewSide? topSide;

  // 底栏容器
  final FocusViewSide? bottomSide;

  // 左栏容器
  final FocusViewSide? leftSide;

  // 右栏容器
  final FocusViewSide? rightSide;

  // 主轴容器间距
  final double mainSpacing;

  // 副轴容器间距
  final double crossSpacing;

  // 内间距
  final EdgeInsetsGeometry padding;

  const FocusView({
    super.key,
    required this.builder,
    this.child,
    this.topSide,
    this.leftSide,
    this.rightSide,
    this.bottomSide,
    this.mainSpacing = 0,
    this.crossSpacing = 0,
    this.isMainAxis = true,
    this.padding = EdgeInsets.zero,
  });

  @override
  State<StatefulWidget> createState() => _FocusViewState();
}

/*
* 焦点控制容器-状态
* @author wuxubaiyang
* @Time 2023/10/26 13:48
*/
class _FocusViewState extends State<FocusView> {
  // 主体内容焦点管理
  final bodyFocusScope = FocusScopeNode();

  @override
  Widget build(BuildContext context) {
    final bodyView = widget.builder(context, bodyFocusScope, widget.child);
    return Padding(
      padding: widget.padding,
      child: widget.isMainAxis
          ? _buildMainAxisView(bodyView)
          : _buildCrossAxisView(bodyView),
    );
  }

  // 构建主轴方向结构（左右展开）
  Widget _buildMainAxisView(Widget child) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.leftSide != null) ...[
          _buildSide(widget.leftSide!),
          SizedBox(width: widget.mainSpacing),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.topSide != null) ...[
                _buildSide(widget.topSide!),
                SizedBox(height: widget.crossSpacing),
              ],
              Expanded(child: _buildBody(child)),
              if (widget.bottomSide != null) ...[
                SizedBox(height: widget.crossSpacing),
                _buildSide(widget.bottomSide!),
              ],
            ],
          ),
        ),
        if (widget.rightSide != null) ...[
          SizedBox(width: widget.mainSpacing),
          _buildSide(widget.rightSide!),
        ],
      ],
    );
  }

  // 构建副轴方向结构（上下展开）
  Widget _buildCrossAxisView(Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.topSide != null) ...[
          _buildSide(widget.topSide!),
          SizedBox(height: widget.crossSpacing),
        ],
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.leftSide != null) ...[
                _buildSide(widget.leftSide!),
                SizedBox(width: widget.mainSpacing),
              ],
              Expanded(child: _buildBody(child)),
              if (widget.rightSide != null) ...[
                SizedBox(width: widget.mainSpacing),
                _buildSide(widget.rightSide!),
              ],
            ],
          ),
        ),
        if (widget.bottomSide != null) ...[
          SizedBox(height: widget.crossSpacing),
          _buildSide(widget.bottomSide!),
        ],
      ],
    );
  }

  // 构建主体容器
  Widget _buildBody(Widget child) {
    return FocusScope(
      node: bodyFocusScope,
      onKeyEvent: _handleFocusKey,
      child: child,
    );
  }

  // 构建侧栏容器
  Widget _buildSide(FocusViewSide side) {
    return ConstrainedBox(
      constraints: side.constraints,
      child: FocusScope(
        node: side.focusScopeNode,
        onKeyEvent: _handleFocusKey,
        onFocusChange: (_) => setState(() {}),
        child: side.getView(context),
      ),
    );
  }

  // 按键方向与焦点移动方向对照表
  final _keyDirectionMap = {
    LogicalKeyboardKey.arrowUp: TraversalDirection.up,
    LogicalKeyboardKey.arrowDown: TraversalDirection.down,
    LogicalKeyboardKey.arrowLeft: TraversalDirection.left,
    LogicalKeyboardKey.arrowRight: TraversalDirection.right,
  };

  // 所有容器焦点二维表
  List<List<FocusScopeNode?>> get _focusSideList => [
        [null, widget.topSide?.focusScopeNode, null],
        [
          widget.leftSide?.focusScopeNode,
          bodyFocusScope,
          widget.rightSide?.focusScopeNode
        ],
        [null, widget.bottomSide?.focusScopeNode, null],
      ];

  // 根据scope焦点缓存离开时的子焦点
  final Map<FocusScopeNode, FocusNode?> _focusScopeNodeCache = {};

  // 从容器焦点结构中找到目标焦点所在位置
  (int, int)? _findFocusNode(FocusNode node) {
    for (int i = 0; i < _focusSideList.length; i++) {
      final sideList = _focusSideList[i];
      for (int j = 0; j < sideList.length; j++) {
        if (sideList[j] == node) {
          return (i, j);
        }
      }
    }
    return null;
  }

  // 找到目标焦点的下一个焦点
  FocusScopeNode? _findNextFocusNode(
          (int, int) position, TraversalDirection direction) =>
      {
        TraversalDirection.up: (int row, int column) {
          if (row <= 0) return null;
          return _focusSideList[row - 1][column];
        },
        TraversalDirection.down: (int row, int column) {
          if (row >= _focusSideList.length - 1) return null;
          return _focusSideList[row + 1][column];
        },
        TraversalDirection.left: (int row, int column) {
          if (column <= 0) return null;
          return _focusSideList[row][column - 1];
        },
        TraversalDirection.right: (int row, int column) {
          if (column >= _focusSideList[row].length - 1) return null;
          return _focusSideList[row][column + 1];
        },
      }[direction]!(position.$1, position.$2);

  // 处理按键事件
  KeyEventResult _handleFocusKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || node is! FocusScopeNode) {
      return KeyEventResult.ignored;
    }
    final direction = _keyDirectionMap[event.logicalKey];
    if (direction == null) return KeyEventResult.ignored;
    // 焦点移动失败则代表移动到了边界，需要跳转到下一个容器
    if (node.focusInDirection(direction)) return KeyEventResult.handled;
    // 找到当前焦点所在位置并根据方向移动
    final position = _findFocusNode(node);
    if (position == null) return KeyEventResult.ignored;
    final nextNode = _findNextFocusNode(position, direction);
    if (nextNode == null) return KeyEventResult.ignored;
    // 缓存当前scope的子元素焦点
    _focusScopeNodeCache[node] = node.focusedChild;
    // 取出缓存/目标scope的第一个元素焦点
    final firstNode = _focusScopeNodeCache[nextNode] ??
        nextNode.traversalDescendants.firstOrNull;
    nextNode.requestFocus(firstNode);
    return KeyEventResult.handled;
  }
}

/*
* 容器配置信息
* @author wuxubaiyang
* @Time 2023/10/27 9:01
*/
class FocusViewSide {
  // 构造器
  final FocusBuilder builder;

  // 组件
  final Widget? child;

  // 尺寸约束
  final BoxConstraints constraints;

  // 焦点控制
  final focusScopeNode = FocusScopeNode();

  FocusViewSide({
    required this.builder,
    this.constraints = const BoxConstraints(),
    this.child,
  });

  // 构建容器组件
  Widget getView(BuildContext context) =>
      builder(context, focusScopeNode, child);
}
