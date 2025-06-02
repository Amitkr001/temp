import 'package:flutter/material.dart';

class CustomRefreshIndicator extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Color color;
  final Widget child;

  const CustomRefreshIndicator({
    Key? key,
    required this.onRefresh,
    required this.color,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(onRefresh: onRefresh, color: color, child: child);
  }
}
