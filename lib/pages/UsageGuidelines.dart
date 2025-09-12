import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Usageguidelines extends StatefulWidget {
  const Usageguidelines({super.key});

  @override
  State<Usageguidelines> createState() => _UsageguidelinesState();
}

class _UsageguidelinesState extends State<Usageguidelines> {
  final List<Map<String, dynamic>> sections = [
    {
      "title": "新手入门",
      "items": ["创建第一个钱包", "获得第一笔加密资产", "完成第一笔交易"],
    },
    {
      "title": "基本概念",
      "items": ["关于钱包", "公链与代币", "转账与接收", "Swap 交易"],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 40,
        leading: GestureDetector(
          onTap: () => {Feedback.forTap(context), Navigator.of(context).pop()},
          child: Icon(Icons.arrow_back_ios_new, size: 20.w, color: Colors.black),
        ),
        centerTitle: true,
        title: Text(
          "使用指南",
          style: TextStyle(fontSize: 18.sp, color: Colors.black, fontWeight: FontWeight.w500),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 12.w),
              child: _buildSearchField(),
            ),
            SizedBox(height: 20.h),
            ...sections.map((section) => _buildSection(section)).toList(),
          ],
        ),
      ),
    );
  }

  /// 搜索框
  Widget _buildSearchField() {
    return TextField(
      cursorColor: Colors.black,
      decoration: InputDecoration(
        hintText: "支持搜索问题、正文关键词",
        hintStyle: TextStyle(fontSize: 14.sp, color: const Color(0xFF909090)),
        filled: true,
        fillColor: const Color(0xFFF3F3F3),
        contentPadding: EdgeInsets.zero,
        border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(25.r)),
        prefixIcon: Icon(Icons.search, color: Colors.black),
      ),
    );
  }

  /// 一个章节
  Widget _buildSection(Map<String, dynamic> section) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 12.w),
            child: Text(
              section["title"],
              style: TextStyle(fontSize: 18.sp, color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 12.h),
          ...List.generate(section["items"].length, (index) {
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
              leading: Text(
                section["items"][index],
                style: TextStyle(fontSize: 16.sp, color: Colors.black),
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 18.w, color: const Color(0xFFA3ADAD)),
              onTap: () {
                // TODO: 点击跳转逻辑
              },
            );
          }),
        ],
      ),
    );
  }
}
