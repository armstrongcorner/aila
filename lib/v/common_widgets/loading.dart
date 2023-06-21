import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class WSLoading extends StatelessWidget {
  WSLoading({
    Key? key,
    required this.inAsyncCall,
    this.opacity = 0.4,
    this.color = Colors.grey,
    this.offset,
    this.dismissible = false,
    this.isEmpty = false,
    this.emptyWidget,
    required Widget? child,
  })  : children = child != null ? [child] : [],
        super(key: key);

  const WSLoading.fromChildren({
    Key? key,
    required this.inAsyncCall,
    this.opacity = 0.3,
    this.color = Colors.grey,
    this.offset,
    this.dismissible = false,
    this.isEmpty = false,
    this.emptyWidget,
    required this.children,
  }) : super(key: key);
  final bool inAsyncCall;
  final double opacity;
  final Color color;
  final Offset? offset;
  final bool dismissible;
  final bool isEmpty;
  final Widget? emptyWidget;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = <Widget>[];
    if (isEmpty) {
      widgetList.add(
        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: emptyWidget ?? Container(),
          ),
        ),
      );
    }
    const Widget progressIndicator = EbProgressIndicator();
    widgetList.addAll(children);
    if (inAsyncCall) {
      Widget layOutProgressIndicator;
      if (offset == null) {
        layOutProgressIndicator = const Center(child: progressIndicator);
      } else {
        layOutProgressIndicator = Positioned(
          left: offset?.dx,
          top: offset?.dy,
          child: progressIndicator,
        );
      }
      final List<Widget> modal = [
        Opacity(
          opacity: opacity,
          child: ModalBarrier(
            dismissible: dismissible,
            color: Colors.black,
          ),
        ),
        layOutProgressIndicator
      ];
      widgetList += modal;
    }

    return Stack(
      children: widgetList,
    );
  }
}

class EbProgressIndicator extends StatelessWidget {
  const EbProgressIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(40),
        ),
        child: kIsWeb
            ? Transform.scale(
                scale: 1.3, child: const CircularProgressIndicator.adaptive())
            : const CircularProgressIndicator.adaptive());
  }
}
