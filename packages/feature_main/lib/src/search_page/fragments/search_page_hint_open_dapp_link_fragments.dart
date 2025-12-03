import 'package:feature_main/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_ui/theme/app_textStyle.dart';

class SearchPageHintOpenDappLinkFragments extends StatelessWidget {
  final String textEditing;
  final Function()? onTap;
  const SearchPageHintOpenDappLinkFragments({super.key, required this.textEditing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        width: double.infinity,
        height: 55.h,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.public, size: 16, color: Theme.of(context).colorScheme.primary),
                    SizedBox(width: 4),
                    Text(t.common.open_link_below, style: AppTextStyles.labelLarge.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                  ],
                ),
                Text(textEditing, style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.primary)),
              ],
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Theme.of(context).colorScheme.onSurface),
          ],
        ),
      ),
    );
  }
}
