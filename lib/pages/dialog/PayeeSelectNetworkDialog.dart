

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../constants/AppColors.dart';
import '../PayeePage.dart';

/*
 *
 */
class PayeeSelectNetworkDialog extends StatefulWidget {
  final String title;
  final List<String> items ;

  const PayeeSelectNetworkDialog({
    Key? key,
    required this.title,
    required this.items,
  }) : super(key: key);

  @override
  State<PayeeSelectNetworkDialog> createState() => _PayeeSelectNetworkDialogState();
}

class _PayeeSelectNetworkDialogState extends State<PayeeSelectNetworkDialog> {

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: EdgeInsets.only(bottom: 20.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18.sp,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 25, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Get.off(PayeePage());
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    color: Colors.white,
                    child: Row(
                      children: [
                        ClipOval(
                          child: Image.asset(
                            'assets/images/ic_home_bit_coin.png',
                            width: 40.w,
                            height: 40.h,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.items[index],
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                'Solana',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: AppColors.color_909090,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              '9.${index}0',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '¥${index + 1}.00',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColors.color_909090,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }


}

