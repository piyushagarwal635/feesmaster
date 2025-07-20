import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class StepIndicatorWidget extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepIndicatorWidget({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        children: List.generate(totalSteps, (index) {
          final bool isActive = index < currentStep;
          final bool isCurrent = index == currentStep - 1;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 0.5.h,
                    decoration: BoxDecoration(
                      color: isActive || isCurrent
                          ? AppTheme.lightTheme.primaryColor
                          : AppTheme.getOutlineColor(isLight),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (index < totalSteps - 1) SizedBox(width: 1.w),
              ],
            ),
          );
        }),
      ),
    );
  }
}
