import 'package:feature_main/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_ui/theme/app_textStyle.dart';

class SearchPageDappFragments extends StatelessWidget {
  const SearchPageDappFragments({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: 30),
        Icon(Icons.search_off_sharp, size: 130, color: Theme.of(context).colorScheme.onSurface),
        SizedBox(height: 20),
        Text(
          t.common.no_matching_results,
          style: AppTextStyles.bodyLarge.copyWith(color: Theme.of(context).colorScheme.onBackground),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
