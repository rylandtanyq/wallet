import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerFragments extends StatelessWidget {
  const ShimmerFragments({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color.fromARGB(150, 224, 224, 224),
      highlightColor: Colors.grey.shade400,
      child: Container(
        width: double.infinity,
        height: 80,
        margin: EdgeInsets.only(bottom: 20),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: const Color.fromARGB(150, 224, 224, 224), borderRadius: BorderRadius.circular(50)),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 3,
                    height: 16,
                    decoration: BoxDecoration(color: const Color.fromARGB(150, 224, 224, 224), borderRadius: BorderRadius.circular(10)),
                  ),
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(color: const Color.fromARGB(150, 224, 224, 224), borderRadius: BorderRadius.circular(10)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
