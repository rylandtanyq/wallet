import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FullScreenDialog extends StatefulWidget {
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
  State<FullScreenDialog> createState() => _FullScreenDialogState();
}

class _FullScreenDialogState extends State<FullScreenDialog> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: widget.title != null ? Text(widget.title!,style: TextStyle(fontSize: 18.sp,fontWeight: FontWeight.bold),) : null,
        leading: widget.showCloseButton
            ? IconButton(
          icon: Icon(Icons.close,size: 15.5.h,),
          onPressed: () => Navigator.pop(context),
        )
            : null,
      ),
      body: widget.child,
    );
  }
}

