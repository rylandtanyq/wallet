import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled1/theme/app_textStyle.dart';

class Createwalletpage extends StatefulWidget {
  const Createwalletpage({super.key});

  @override
  State<Createwalletpage> createState() => _CreatewalletpageState();
}

class _CreatewalletpageState extends State<Createwalletpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Image.asset('assets/icon/app_icon_launch.png', width: 200.sp, height: 200.sp),
            ),
            Text("开启你的Web3之旅", style: AppTextStyles.headline1.copyWith(color: Theme.of(context).colorScheme.onBackground)),
            SizedBox(height: 20.h),
            Container(
              width: double.infinity,
              height: 40.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: TextButton(
                style: ButtonStyle(backgroundColor: WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.primary)),
                onPressed: () {},
                child: Text("创建钱包", style: AppTextStyles.bodyLarge.copyWith(color: Theme.of(context).colorScheme.onPrimary)),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
