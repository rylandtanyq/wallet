import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled1/constants/app_colors.dart';
import 'package:untitled1/i18n/strings.g.dart';
import 'package:untitled1/theme/app_textStyle.dart';

class StatefulProductCard extends StatefulWidget {
  @override
  _StatefulProductCardState createState() => _StatefulProductCardState();
}

class _StatefulProductCardState extends State<StatefulProductCard> {
  int _remainingDays = 10; // 剩余天数
  int _participants = 20777; // 参与人数
  bool _isParticipated = false; // 是否已参与

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  // 倒计时逻辑
  void _startCountdown() {
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          if (_remainingDays > 0) {
            _remainingDays--;
          }
        });
        _startCountdown();
      }
    });
  }

  // 参与按钮点击事件
  void _handleParticipate() {
    setState(() {
      _isParticipated = true;
      _participants += 1;
    });

    // 显示参与成功的提示
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('参与成功！'), duration: Duration(seconds: 2)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(.4), width: 1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 202,
                    child: Text(
                      t.home.hold_syrupusdc,
                      style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: 8),

                  SizedBox(
                    width: 202,
                    child: Text(
                      t.home.syrupusdc_desc,
                      style: AppTextStyles.labelMedium.copyWith(color: Theme.of(context).colorScheme.onSurface),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: 4),
                  // 描述文字
                  // Text('SOLBOT机构推出的稳定币收...', style: AppTextStyles.labelMedium.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                ],
              ),
              ClipOval(
                child: Image.asset('assets/images/ic_home_center_imge.jpg', width: 60.w, height: 60.w, fit: BoxFit.cover),
              ),
            ],
          ),

          SizedBox(height: 12),

          // 倒计时
          Row(
            children: [
              SizedBox(width: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.color_FBFFF1,
                  borderRadius: BorderRadius.circular(5.r),
                  border: Border.all(color: AppColors.color_B5DE5B, width: 0.5),
                ),
                child: Text(t.home.ends_in, style: AppTextStyles.size13.copyWith(color: Theme.of(context).colorScheme.primary)),
              ),
              SizedBox(width: 3.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.color_FBFFF1,
                  borderRadius: BorderRadius.circular(5.r),
                  border: Border.all(color: AppColors.color_B5DE5B, width: 0.5),
                ),
                child: Text('HOT', style: TextStyle(color: AppColors.color_2B6D16, fontSize: 12)),
              ),
            ],
          ),
          SizedBox(height: 19.h),
          Divider(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(.4),
            height: 1, // 线的高度
            thickness: 1, // 线的粗细
          ),
          SizedBox(height: 13.h),
          // 奖励信息和参与人数
          Row(
            children: [
              ClipOval(
                child: Image.asset('assets/images/ic_home_bit_coin.png', width: 13.w, height: 13.w, fit: BoxFit.cover),
              ),
              Text(t.home.total_reward, style: AppTextStyles.size13.copyWith(color: Theme.of(context).colorScheme.onSurface)),
              Text(
                '\$100,000',
                style: AppTextStyles.size13.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 时间信息
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.access_time, size: 13.w, color: Theme.of(context).colorScheme.onSurface),
                        Text(t.home.duration_abbr, style: AppTextStyles.size13.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                        Text(
                          '2分钟',
                          style: AppTextStyles.size13.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    // 参与人数
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.person_outline, size: 13.w, color: Theme.of(context).colorScheme.onSurface),
                        Text(t.home.join_now_abbr, style: AppTextStyles.size13.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                        Text(
                          '200人',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: AppTextStyles.size13.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(width: 10.w),

              SizedBox(
                width: 104.w,
                height: 30.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isParticipated ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(45)),
                    padding: EdgeInsets.symmetric(vertical: 5),
                  ),
                  onPressed: _isParticipated ? null : _handleParticipate,
                  child: Text(
                    _isParticipated ? t.home.participated : t.home.join_now,
                    style: AppTextStyles.size15.copyWith(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
