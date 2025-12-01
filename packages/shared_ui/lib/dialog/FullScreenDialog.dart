import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FullScreenDialog extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool showCloseButton;

  const FullScreenDialog({
    required this.child,
    this.title,
    this.showCloseButton = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: title != null ? Text(title!,style: TextStyle(fontSize: 18.sp,fontWeight: FontWeight.bold),) : null,
        leading: showCloseButton
            ? IconButton(
          icon: Icon(Icons.close,size: 20.h,),
          onPressed: () => Navigator.pop(context),
        )
            : null,
      ),
      body: child,
    );
  }
}

