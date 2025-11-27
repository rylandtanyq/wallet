import 'package:flutter/material.dart';

class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar child;
  final Color backgroundColor;

  StickyTabBarDelegate({required this.child, this.backgroundColor = Colors.white});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      color: Theme.of(context).colorScheme.background,
      child: Container(color: Theme.of(context).colorScheme.background, height: child.preferredSize.height, child: child),
    );
  }

  @override
  double get maxExtent => child.preferredSize.height;

  @override
  double get minExtent => child.preferredSize.height;

  @override
  bool shouldRebuild(StickyTabBarDelegate oldDelegate) {
    return child != oldDelegate.child || backgroundColor != oldDelegate.backgroundColor;
  }
}
