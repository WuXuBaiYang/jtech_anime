import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/*
* 双元素监听构造
* @author wuxubaiyang
* @Time 2022/10/20 17:03
*/
class ValueListenableBuilder2<A, B> extends StatelessWidget {
  final ValueListenable<A> first;
  final ValueListenable<B> second;
  final Widget? child;
  final Widget Function(BuildContext context, A a, B b, Widget? child) builder;

  const ValueListenableBuilder2({
    required this.first,
    required this.second,
    Key? key,
    required this.builder,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<A>(
        valueListenable: first,
        builder: (_, a, __) {
          return ValueListenableBuilder<B>(
            valueListenable: second,
            builder: (context, b, __) {
              return builder(context, a, b, child);
            },
          );
        },
      );
}

/*
* 三元素监听构造
* @author wuxubaiyang
* @Time 2022/10/20 17:03
*/
class ValueListenableBuilder3<A, B, C> extends StatelessWidget {
  final ValueListenable<A> first;
  final ValueListenable<B> second;
  final ValueListenable<C> third;
  final Widget? child;
  final Widget Function(BuildContext context, A a, B b, C c, Widget? child)
      builder;

  const ValueListenableBuilder3({
    required this.first,
    required this.second,
    required this.third,
    Key? key,
    required this.builder,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<A>(
        valueListenable: first,
        builder: (_, a, __) {
          return ValueListenableBuilder<B>(
            valueListenable: second,
            builder: (context, b, __) {
              return ValueListenableBuilder<C>(
                valueListenable: third,
                builder: (context, c, __) {
                  return builder(context, a, b, c, child);
                },
              );
            },
          );
        },
      );
}
