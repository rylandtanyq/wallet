import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled1/constants/AppColors.dart';

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('参与成功！'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFE8EEEE),
          width: 1,
        ),
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
                  Text(
                    '持有WPoS享20...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),

                  Text(
                    'WPoS是由SOLBOT机构....',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  // 描述文字
                  Text(
                    'SOLBOT机构推出的稳定币收...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),

                ],
              ),
              ClipOval(
                child: Image.asset(
                  'assets/images/ic_home_center_imge.jpg',
                  width: 60.w,
                  height: 60.w,
                  fit: BoxFit.cover,
                ),
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
                  border: Border.all(
                    color: AppColors.color_B5DE5B,
                    width: 0.5,
                  ),
                ),
                child: Text(
                  '距结束：$_remainingDays天',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.color_2B6D16,
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.color_FBFFF1,
                  borderRadius: BorderRadius.circular(5.r),
                  border: Border.all(
                    color: AppColors.color_B5DE5B,
                    width: 0.5,
                  ),
                ),
                child: Text(
                  'HOT',
                  style: TextStyle(
                    color: AppColors.color_2B6D16,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 19.h),
          Divider(
            color: Color(0xFFEFEFEF),
            height: 1,  // 线的高度
            thickness: 1,  // 线的粗细
          ),
          SizedBox(height: 13.h),
          // 奖励信息和参与人数
          Row(
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/images/ic_home_bit_coin.png',
                  width: 13.w,
                  height: 13.w,
                  fit: BoxFit.cover,
                ),
              ),
              Text(
                '总奖励  ',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey,
                ),
              ),
              Text(
                '\$100,000',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.color_2B6D16
                ),
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
                        Icon(Icons.access_time, size: 13.w, color: Colors.grey),
                        Text(
                          '耗时 ',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '2分钟',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    
                    // 参与人数
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.person_outline, size: 13.w, color: Colors.grey),
                        Text(
                          '参与人数 ',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '200人',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1, 
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                          ),
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
                    backgroundColor: _isParticipated ? Colors.grey : AppColors.color_2B6D16,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(45),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 5),
                  ),
                  onPressed: _isParticipated ? null : _handleParticipate,
                  child: Text(
                    _isParticipated ? '已参与' : '立即参与',
                    style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    ),
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