import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CourseSelectionStepWidget extends StatefulWidget {
  final Map<String, dynamic> studentData;
  final Function(Map<String, dynamic>) onDataChanged;

  const CourseSelectionStepWidget({
    Key? key,
    required this.studentData,
    required this.onDataChanged,
  }) : super(key: key);

  @override
  State<CourseSelectionStepWidget> createState() =>
      _CourseSelectionStepWidgetState();
}

class _CourseSelectionStepWidgetState extends State<CourseSelectionStepWidget> {
  final _searchController = TextEditingController();
  String? _selectedCourse;
  String? _selectedBatch;
  List<String> _filteredCourses = [];

  final List<Map<String, dynamic>> _courses = [
    {
      'id': 'math_basic',
      'name': 'Mathematics - Basic',
      'duration': '6 months',
      'fee': 2500.0,
      'batches': [
        {
          'id': 'math_basic_morning',
          'name': 'Morning Batch (8:00 AM - 10:00 AM)',
          'slots': 15
        },
        {
          'id': 'math_basic_evening',
          'name': 'Evening Batch (6:00 PM - 8:00 PM)',
          'slots': 8
        },
      ],
    },
    {
      'id': 'math_advanced',
      'name': 'Mathematics - Advanced',
      'duration': '8 months',
      'fee': 3500.0,
      'batches': [
        {
          'id': 'math_adv_morning',
          'name': 'Morning Batch (9:00 AM - 11:00 AM)',
          'slots': 12
        },
        {
          'id': 'math_adv_afternoon',
          'name': 'Afternoon Batch (2:00 PM - 4:00 PM)',
          'slots': 20
        },
      ],
    },
    {
      'id': 'physics_foundation',
      'name': 'Physics - Foundation',
      'duration': '5 months',
      'fee': 2200.0,
      'batches': [
        {
          'id': 'physics_found_morning',
          'name': 'Morning Batch (7:00 AM - 9:00 AM)',
          'slots': 18
        },
        {
          'id': 'physics_found_evening',
          'name': 'Evening Batch (5:00 PM - 7:00 PM)',
          'slots': 5
        },
      ],
    },
    {
      'id': 'chemistry_organic',
      'name': 'Chemistry - Organic',
      'duration': '7 months',
      'fee': 3000.0,
      'batches': [
        {
          'id': 'chem_org_morning',
          'name': 'Morning Batch (10:00 AM - 12:00 PM)',
          'slots': 10
        },
        {
          'id': 'chem_org_weekend',
          'name': 'Weekend Batch (Sat-Sun 9:00 AM - 1:00 PM)',
          'slots': 25
        },
      ],
    },
    {
      'id': 'english_communication',
      'name': 'English - Communication Skills',
      'duration': '4 months',
      'fee': 1800.0,
      'batches': [
        {
          'id': 'eng_comm_morning',
          'name': 'Morning Batch (8:30 AM - 10:30 AM)',
          'slots': 22
        },
        {
          'id': 'eng_comm_evening',
          'name': 'Evening Batch (7:00 PM - 9:00 PM)',
          'slots': 14
        },
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _filteredCourses =
        _courses.map((course) => course['name'] as String).toList();
    _selectedCourse = widget.studentData['course'];
    _selectedBatch = widget.studentData['batch'];
  }

  void _filterCourses(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCourses =
            _courses.map((course) => course['name'] as String).toList();
      } else {
        _filteredCourses = _courses
            .where((course) => (course['name'] as String)
                .toLowerCase()
                .contains(query.toLowerCase()))
            .map((course) => course['name'] as String)
            .toList();
      }
    });
  }

  Map<String, dynamic>? _getSelectedCourseData() {
    if (_selectedCourse == null) return null;
    return _courses.firstWhere(
      (course) => course['name'] == _selectedCourse,
      orElse: () => {},
    );
  }

  List<Map<String, dynamic>> _getAvailableBatches() {
    final courseData = _getSelectedCourseData();
    if (courseData == null) return [];
    return (courseData['batches'] as List<Map<String, dynamic>>);
  }

  void _updateStudentData() {
    final courseData = _getSelectedCourseData();
    final updatedData = {
      ...widget.studentData,
      'course': _selectedCourse,
      'batch': _selectedBatch,
      'courseFee': courseData?['fee'],
      'courseDuration': courseData?['duration'],
    };
    widget.onDataChanged(updatedData);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final courseData = _getSelectedCourseData();
    final availableBatches = _getAvailableBatches();

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Course Selection',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 3.h),

          // Course Search and Selection
          Text(
            'Select Course *',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          SizedBox(height: 1.h),

          TextFormField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search Courses',
              hintText: 'Type to search courses',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'search',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 20,
                ),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        _filterCourses('');
                      },
                      child: Padding(
                        padding: EdgeInsets.all(3.w),
                        child: CustomIconWidget(
                          iconName: 'clear',
                          color: AppTheme.lightTheme.primaryColor,
                          size: 20,
                        ),
                      ),
                    )
                  : null,
            ),
            onChanged: _filterCourses,
          ),
          SizedBox(height: 2.h),

          // Course List
          Container(
            constraints: BoxConstraints(maxHeight: 25.h),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredCourses.length,
              itemBuilder: (context, index) {
                final courseName = _filteredCourses[index];
                final course =
                    _courses.firstWhere((c) => c['name'] == courseName);
                final isSelected = _selectedCourse == courseName;

                return Container(
                  margin: EdgeInsets.only(bottom: 1.h),
                  child: Card(
                    elevation: isSelected ? 4 : 1,
                    color: isSelected
                        ? AppTheme.lightTheme.primaryColor
                            .withValues(alpha: 0.1)
                        : AppTheme.getSurfaceVariant(isLight),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(3.w),
                      leading: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.lightTheme.primaryColor
                              : AppTheme.getOutlineColor(isLight),
                          shape: BoxShape.circle,
                        ),
                        child: CustomIconWidget(
                          iconName: 'school',
                          color: isSelected
                              ? Colors.white
                              : AppTheme.lightTheme.primaryColor,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        courseName,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppTheme.lightTheme.primaryColor
                                      : null,
                                ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 0.5.h),
                          Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'schedule',
                                color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color ??
                                    Colors.grey,
                                size: 16,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                'Duration: ${course['duration']}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          SizedBox(height: 0.5.h),
                          Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'attach_money',
                                color: AppTheme.getSuccessColor(isLight),
                                size: 16,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                'Fee: \$${course['fee']}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppTheme.getSuccessColor(isLight),
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: isSelected
                          ? CustomIconWidget(
                              iconName: 'check_circle',
                              color: AppTheme.lightTheme.primaryColor,
                              size: 24,
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedCourse = courseName;
                          _selectedBatch = null; // Reset batch selection
                        });
                        _updateStudentData();
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          if (_selectedCourse != null) ...[
            SizedBox(height: 3.h),

            // Batch Selection
            Text(
              'Select Batch *',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            SizedBox(height: 1.h),

            ...availableBatches.map((batch) {
              final isSelected = _selectedBatch == batch['id'];
              final availableSlots = batch['slots'] as int;
              final isAvailable = availableSlots > 0;

              return Container(
                margin: EdgeInsets.only(bottom: 1.h),
                child: Card(
                  elevation: isSelected ? 4 : 1,
                  color: isSelected
                      ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1)
                      : AppTheme.getSurfaceVariant(isLight),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(3.w),
                    leading: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.lightTheme.primaryColor
                            : (isAvailable
                                ? AppTheme.getSuccessColor(isLight)
                                : AppTheme.getErrorColor(isLight)),
                        shape: BoxShape.circle,
                      ),
                      child: CustomIconWidget(
                        iconName: isAvailable ? 'group' : 'group_off',
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      batch['name'],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected
                                ? AppTheme.lightTheme.primaryColor
                                : null,
                          ),
                    ),
                    subtitle: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'event_seat',
                          color: isAvailable
                              ? AppTheme.getSuccessColor(isLight)
                              : AppTheme.getErrorColor(isLight),
                          size: 16,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          '$availableSlots slots available',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isAvailable
                                        ? AppTheme.getSuccessColor(isLight)
                                        : AppTheme.getErrorColor(isLight),
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                    trailing: isSelected
                        ? CustomIconWidget(
                            iconName: 'check_circle',
                            color: AppTheme.lightTheme.primaryColor,
                            size: 24,
                          )
                        : null,
                    enabled: isAvailable,
                    onTap: isAvailable
                        ? () {
                            setState(() {
                              _selectedBatch = batch['id'];
                            });
                            _updateStudentData();
                          }
                        : null,
                  ),
                ),
              );
            }).toList(),

            SizedBox(height: 3.h),

            // Fee Structure Display
            if (courseData != null)
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color:
                      AppTheme.getSuccessColor(isLight).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.getSuccessColor(isLight)
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'receipt',
                          color: AppTheme.getSuccessColor(isLight),
                          size: 24,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Fee Structure',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.getSuccessColor(isLight),
                                  ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Course Fee:',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          '\$${courseData['fee']}',
                          style: AppTheme.dataTextStyleEmphasis(
                            isLight: isLight,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Duration:',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          courseData['duration'],
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
