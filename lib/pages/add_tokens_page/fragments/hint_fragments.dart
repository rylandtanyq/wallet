import 'package:flutter/material.dart';
import 'package:untitled1/theme/app_textStyle.dart';

class HintFragments extends StatelessWidget {
  final Widget icons;
  final String hitTitle;
  final String? hitSubtitle;
  const HintFragments({super.key, required this.icons, required this.hitTitle, this.hitSubtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80,
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(10)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icons,
          Text(hitTitle, style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onBackground)),
          if (hitSubtitle != null) Text(hitSubtitle!, style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onBackground)),
        ],
      ),
    );
  }
}
