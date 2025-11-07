import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonFragments extends StatelessWidget {
  const SkeletonFragments({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color.fromARGB(150, 224, 224, 224),
      highlightColor: Colors.grey.shade400,
      child: Container(
        width: 100,
        height: 20,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: const Color.fromARGB(150, 224, 224, 224)),
      ),
    );
  }
}
