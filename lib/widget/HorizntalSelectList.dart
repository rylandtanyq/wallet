import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/AppColors.dart';

class HorizontalSelectList extends StatefulWidget {
  final List<String> items;
  final ValueChanged<int>? onSelected;

  const HorizontalSelectList({Key? key, required this.items, this.onSelected}) : super(key: key);

  @override
  _HorizontalSelectListState createState() => _HorizontalSelectListState();
}

class _HorizontalSelectListState extends State<HorizontalSelectList> {
  final ScrollController _scrollController = ScrollController();
  late List<String> items;
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    items = widget.items;
    selectedIndex = 0;
  }

  void _selectItem(int index) {
    setState(() {
      selectedIndex = index;
    });
    widget.onSelected?.call(index);
    // 计算是否需要滚动到中间
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = 100.0; // 每个item宽度为100
    final offset = (index - 2) * itemWidth - (screenWidth / 2 - itemWidth * 2.5);

    _scrollController.animateTo(
      offset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 8.h),
        Container(
          height: 25.h,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _selectItem(index),
                child: Container(
                  height: 25.h,
                  padding: EdgeInsets.only(left: 4.w, right: 10.w, bottom: 1.h, top: 1.h),
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: selectedIndex == index ? Theme.of(context).colorScheme.onBackground : Theme.of(context).colorScheme.onSurface,
                      width: 1.h,
                    ),
                  ),
                  child: Center(
                    child: Row(
                      children: [
                        ClipOval(
                          child: Image.asset('assets/images/ic_home_bit_coin.png', width: 20.w, height: 20.h),
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          items[index],
                          style: TextStyle(
                            color: selectedIndex == index ? Theme.of(context).colorScheme.onBackground : Theme.of(context).colorScheme.onSurface,
                            fontSize: 15.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
