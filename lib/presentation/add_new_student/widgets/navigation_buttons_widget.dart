import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NavigationButtonsWidget extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onSaveDraft;
  final VoidCallback? onSaveFinish;
  final bool canProceed;
  final bool isLoading;

  const NavigationButtonsWidget({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
    this.onPrevious,
    this.onNext,
    this.onSaveDraft,
    this.onSaveFinish,
    this.canProceed = true,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final bool isFirstStep = currentStep == 1;
    final bool isLastStep = currentStep == totalSteps;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceVariant(isLight),
        border: Border(
          top: BorderSide(
            color: AppTheme.getOutlineColor(isLight),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Save Draft Button
            if (!isLastStep)
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 2.h),
                child: TextButton.icon(
                  onPressed: isLoading ? null : onSaveDraft,
                  icon: isLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.lightTheme.primaryColor,
                          ),
                        )
                      : CustomIconWidget(
                          iconName: 'save',
                          color: AppTheme.lightTheme.primaryColor,
                          size: 18,
                        ),
                  label: Text(
                    isLoading ? 'Saving...' : 'Save Draft',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTheme.primaryColor,
                        ),
                  ),
                ),
              ),

            // Navigation Buttons Row
            Row(
              children: [
                // Previous Button
                if (!isFirstStep)
                  Expanded(
                    flex: 1,
                    child: OutlinedButton.icon(
                      onPressed: isLoading ? null : onPrevious,
                      icon: CustomIconWidget(
                        iconName: 'arrow_back',
                        color: isLoading
                            ? AppTheme.getOutlineColor(isLight)
                            : AppTheme.lightTheme.primaryColor,
                        size: 18,
                      ),
                      label: Text('Previous'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 3.w),
                        foregroundColor: isLoading
                            ? AppTheme.getOutlineColor(isLight)
                            : AppTheme.lightTheme.primaryColor,
                        side: BorderSide(
                          color: isLoading
                              ? AppTheme.getOutlineColor(isLight)
                              : AppTheme.lightTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),

                if (!isFirstStep) SizedBox(width: 2.w),

                // Next/Finish Button
                Expanded(
                  flex: isFirstStep ? 1 : 2,
                  child: ElevatedButton.icon(
                    onPressed: (isLoading || !canProceed)
                        ? null
                        : (isLastStep ? onSaveFinish : onNext),
                    icon: isLoading
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : CustomIconWidget(
                            iconName: isLastStep ? 'check' : 'arrow_forward',
                            color: Colors.white,
                            size: 18,
                          ),
                    label: Text(
                      isLoading
                          ? (isLastStep ? 'Saving...' : 'Processing...')
                          : (isLastStep ? 'Save & Finish' : 'Next'),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 3.w),
                      backgroundColor: (isLoading || !canProceed)
                          ? AppTheme.getOutlineColor(isLight)
                          : (isLastStep
                              ? AppTheme.getSuccessColor(isLight)
                              : AppTheme.lightTheme.primaryColor),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            // Step Indicator Text
            SizedBox(height: 2.h),
            Text(
              'Step $currentStep of $totalSteps',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
            ),

            // Validation Message
            if (!canProceed && !isLoading)
              Container(
                margin: EdgeInsets.only(top: 1.h),
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color:
                      AppTheme.getWarningColor(isLight).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: AppTheme.getWarningColor(isLight)
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'warning',
                      color: AppTheme.getWarningColor(isLight),
                      size: 16,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'Please complete all required fields',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.getWarningColor(isLight),
                          ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
