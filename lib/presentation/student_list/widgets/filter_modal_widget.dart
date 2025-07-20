import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterModalWidget extends StatefulWidget {
  final Map<String, List<String>> availableFilters;
  final Map<String, List<String>> selectedFilters;
  final Function(Map<String, List<String>>) onFiltersChanged;

  const FilterModalWidget({
    Key? key,
    required this.availableFilters,
    required this.selectedFilters,
    required this.onFiltersChanged,
  }) : super(key: key);

  @override
  State<FilterModalWidget> createState() => _FilterModalWidgetState();
}

class _FilterModalWidgetState extends State<FilterModalWidget> {
  late Map<String, List<String>> _tempSelectedFilters;
  final Map<String, bool> _expandedSections = {};

  @override
  void initState() {
    super.initState();
    _tempSelectedFilters = Map.from(widget.selectedFilters);

    // Initialize expanded sections
    widget.availableFilters.keys.forEach((key) {
      _expandedSections[key] = true;
    });
  }

  void _toggleFilter(String category, String value) {
    setState(() {
      if (_tempSelectedFilters[category] == null) {
        _tempSelectedFilters[category] = [];
      }

      if (_tempSelectedFilters[category]!.contains(value)) {
        _tempSelectedFilters[category]!.remove(value);
        if (_tempSelectedFilters[category]!.isEmpty) {
          _tempSelectedFilters.remove(category);
        }
      } else {
        _tempSelectedFilters[category]!.add(value);
      }
    });
  }

  void _clearAllFilters() {
    setState(() {
      _tempSelectedFilters.clear();
    });
  }

  void _applyFilters() {
    widget.onFiltersChanged(_tempSelectedFilters);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      height: 90.h,
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceVariant(isLight),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.colorScheme.shadow,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 6.w,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Filter Students',
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                TextButton(
                  onPressed: _clearAllFilters,
                  child: Text(
                    'Clear All',
                    style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filter Content
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(4.w),
              children: widget.availableFilters.entries.map((entry) {
                final String category = entry.key;
                final List<String> options = entry.value;
                final bool isExpanded = _expandedSections[category] ?? false;

                return Container(
                  margin: EdgeInsets.only(bottom: 3.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.lightTheme.colorScheme.shadow,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          setState(() {
                            _expandedSections[category] = !isExpanded;
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.all(4.w),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  category.replaceAll('_', ' ').toUpperCase(),
                                  style: AppTheme
                                      .lightTheme.textTheme.titleMedium
                                      ?.copyWith(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (_tempSelectedFilters[category]?.isNotEmpty ==
                                  true)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 2.w, vertical: 0.5.h),
                                  decoration: BoxDecoration(
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _tempSelectedFilters[category]!
                                        .length
                                        .toString(),
                                    style: AppTheme
                                        .lightTheme.textTheme.labelSmall
                                        ?.copyWith(
                                      color: Colors.white,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              SizedBox(width: 2.w),
                              CustomIconWidget(
                                iconName:
                                    isExpanded ? 'expand_less' : 'expand_more',
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                                size: 5.w,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isExpanded) ...[
                        Divider(
                          color: AppTheme.getOutlineColor(isLight),
                          height: 1,
                        ),
                        Padding(
                          padding: EdgeInsets.all(4.w),
                          child: Wrap(
                            spacing: 2.w,
                            runSpacing: 1.h,
                            children: options.map((option) {
                              final bool isSelected =
                                  _tempSelectedFilters[category]
                                          ?.contains(option) ??
                                      false;

                              return FilterChip(
                                label: Text(
                                  option,
                                  style: AppTheme
                                      .lightTheme.textTheme.labelMedium
                                      ?.copyWith(
                                    fontSize: 12.sp,
                                    color: isSelected
                                        ? AppTheme
                                            .lightTheme.colorScheme.primary
                                        : AppTheme
                                            .lightTheme.colorScheme.onSurface,
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: (selected) =>
                                    _toggleFilter(category, option),
                                backgroundColor:
                                    AppTheme.getSurfaceVariant(isLight),
                                selectedColor: AppTheme
                                    .lightTheme.colorScheme.primary
                                    .withValues(alpha: 0.1),
                                checkmarkColor:
                                    AppTheme.lightTheme.colorScheme.primary,
                                side: BorderSide(
                                  color: isSelected
                                      ? AppTheme.lightTheme.colorScheme.primary
                                      : AppTheme.getOutlineColor(isLight),
                                  width: 1,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          // Apply Button
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.colorScheme.shadow,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                ),
                child: Text(
                  'Apply Filters',
                  style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
