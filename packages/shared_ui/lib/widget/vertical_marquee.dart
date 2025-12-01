import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/*
 * 首页消息跑马灯效果
 */
class VerticalMarquee extends StatefulWidget {
  final List<String> items;
  final double itemHeight;
  final Duration scrollDuration;

  const VerticalMarquee({super.key, required this.items, this.itemHeight = 50.0, this.scrollDuration = const Duration(seconds: 10)});

  @override
  _VerticalMarqueeState createState() => _VerticalMarqueeState();
}

class _VerticalMarqueeState extends State<VerticalMarquee> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _controller = AnimationController(duration: widget.scrollDuration, vsync: this)..repeat();

    _controller.addListener(() {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        _scrollController.animateTo(maxScroll * _controller.value, duration: Duration.zero, curve: Curves.linear);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.itemHeight,
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(10),
        controller: _scrollController,
        itemCount: widget.items.length * 3, // 重复3次实现无缝滚动
        itemBuilder: (context, index) {
          final item = widget.items[index % widget.items.length];
          return SizedBox(
            height: widget.itemHeight,
            child: Row(
              children: [
                Image.asset('assets/images/ic_home_sound.png', width: 12.5.w, height: 11),
                SizedBox(width: 5.w),
                Expanded(
                  child: Text(
                    item,
                    overflow: TextOverflow.ellipsis, // 超出显示...
                    maxLines: 1,
                    style: TextStyle(fontSize: 12.sp, color: Colors.black),
                  ),
                ),
                SizedBox(width: 5.w),
                Image.asset('assets/images/ic_arrows_right.png', width: 7, height: 12),
              ],
            ),
          );
        },
      ),
    );
  }
}
