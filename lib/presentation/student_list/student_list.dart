import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_chips_widget.dart';
import './widgets/filter_modal_widget.dart';
import './widgets/multi_select_actions_widget.dart';
import './widgets/search_bar_widget.dart';
import './widgets/student_card_widget.dart';

class StudentList extends StatefulWidget {
  const StudentList({Key? key}) : super(key: key);

  @override
  State<StudentList> createState() => _StudentListState();
}

class _StudentListState extends State<StudentList>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  // Search and filter state
  String _searchQuery = '';
  Map<String, List<String>> _selectedFilters = {};
  List<Map<String, dynamic>> _activeFilterChips = [];

  // Multi-select state
  bool _isMultiSelectMode = false;
  Set<int> _selectedStudentIds = {};

  // Mock data
  final List<Map<String, dynamic>> _allStudents = [
    {
      "id": 1,
      "name": "Emma Johnson",
      "profilePhoto":
          "https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=400",
      "course": "Mathematics",
      "batch": "Morning A",
      "feeStatus": "paid",
      "feeAmount": "\$1,200.00",
      "nextDueDate": "Jan 15, 2025",
      "email": "emma.johnson@email.com",
      "phone": "+1 (555) 123-4567"
    },
    {
      "id": 2,
      "name": "Michael Chen",
      "profilePhoto":
          "https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg?auto=compress&cs=tinysrgb&w=400",
      "course": "Physics",
      "batch": "Evening B",
      "feeStatus": "due",
      "feeAmount": "\$1,500.00",
      "nextDueDate": "Jan 10, 2025",
      "email": "michael.chen@email.com",
      "phone": "+1 (555) 234-5678"
    },
    {
      "id": 3,
      "name": "Sarah Williams",
      "profilePhoto":
          "https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=400",
      "course": "Chemistry",
      "batch": "Morning A",
      "feeStatus": "overdue",
      "feeAmount": "\$1,350.00",
      "nextDueDate": "Dec 28, 2024",
      "email": "sarah.williams@email.com",
      "phone": "+1 (555) 345-6789"
    },
    {
      "id": 4,
      "name": "David Rodriguez",
      "profilePhoto":
          "https://images.pexels.com/photos/1681010/pexels-photo-1681010.jpeg?auto=compress&cs=tinysrgb&w=400",
      "course": "Biology",
      "batch": "Afternoon C",
      "feeStatus": "paid",
      "feeAmount": "\$1,100.00",
      "nextDueDate": "Feb 01, 2025",
      "email": "david.rodriguez@email.com",
      "phone": "+1 (555) 456-7890"
    },
    {
      "id": 5,
      "name": "Lisa Thompson",
      "profilePhoto":
          "https://images.pexels.com/photos/1130626/pexels-photo-1130626.jpeg?auto=compress&cs=tinysrgb&w=400",
      "course": "Mathematics",
      "batch": "Evening B",
      "feeStatus": "due",
      "feeAmount": "\$1,250.00",
      "nextDueDate": "Jan 12, 2025",
      "email": "lisa.thompson@email.com",
      "phone": "+1 (555) 567-8901"
    },
    {
      "id": 6,
      "name": "James Wilson",
      "profilePhoto":
          "https://images.pexels.com/photos/1043471/pexels-photo-1043471.jpeg?auto=compress&cs=tinysrgb&w=400",
      "course": "Physics",
      "batch": "Morning A",
      "feeStatus": "paid",
      "feeAmount": "\$1,400.00",
      "nextDueDate": "Jan 20, 2025",
      "email": "james.wilson@email.com",
      "phone": "+1 (555) 678-9012"
    },
    {
      "id": 7,
      "name": "Maria Garcia",
      "profilePhoto":
          "https://images.pexels.com/photos/1036623/pexels-photo-1036623.jpeg?auto=compress&cs=tinysrgb&w=400",
      "course": "Chemistry",
      "batch": "Afternoon C",
      "feeStatus": "overdue",
      "feeAmount": "\$1,300.00",
      "nextDueDate": "Dec 30, 2024",
      "email": "maria.garcia@email.com",
      "phone": "+1 (555) 789-0123"
    },
    {
      "id": 8,
      "name": "Robert Brown",
      "profilePhoto":
          "https://images.pexels.com/photos/1212984/pexels-photo-1212984.jpeg?auto=compress&cs=tinysrgb&w=400",
      "course": "Biology",
      "batch": "Evening B",
      "feeStatus": "due",
      "feeAmount": "\$1,150.00",
      "nextDueDate": "Jan 08, 2025",
      "email": "robert.brown@email.com",
      "phone": "+1 (555) 890-1234"
    }
  ];

  final Map<String, List<String>> _availableFilters = {
    'course': ['Mathematics', 'Physics', 'Chemistry', 'Biology'],
    'batch': ['Morning A', 'Evening B', 'Afternoon C'],
    'fee_status': ['paid', 'due', 'overdue'],
    'due_date': ['This Week', 'This Month', 'Overdue', 'Next Month'],
  };

  List<Map<String, dynamic>> _filteredStudents = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 1);
    _filteredStudents = List.from(_allStudents);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _filterStudents() {
    setState(() {
      _filteredStudents = _allStudents.where((student) {
        // Search filter
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          final name = (student['name'] as String).toLowerCase();
          final course = (student['course'] as String).toLowerCase();
          final batch = (student['batch'] as String).toLowerCase();

          if (!name.contains(query) &&
              !course.contains(query) &&
              !batch.contains(query)) {
            return false;
          }
        }

        // Category filters
        for (final entry in _selectedFilters.entries) {
          final category = entry.key;
          final values = entry.value;

          if (values.isEmpty) continue;

          switch (category) {
            case 'course':
              if (!values.contains(student['course'])) return false;
              break;
            case 'batch':
              if (!values.contains(student['batch'])) return false;
              break;
            case 'fee_status':
              if (!values.contains(student['feeStatus'])) return false;
              break;
            case 'due_date':
              // Simplified due date filtering
              final status = student['feeStatus'] as String;
              if (values.contains('Overdue') && status != 'overdue')
                return false;
              if (values.contains('This Week') && status == 'paid')
                return false;
              break;
          }
        }

        return true;
      }).toList();
    });
  }

  void _updateActiveFilterChips() {
    _activeFilterChips.clear();

    for (final entry in _selectedFilters.entries) {
      final category = entry.key;
      final values = entry.value;

      for (final value in values) {
        _activeFilterChips.add({
          'type': category,
          'value': value,
          'label': value.replaceAll('_', ' ').toUpperCase(),
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _filterStudents();
  }

  void _onFiltersChanged(Map<String, List<String>> filters) {
    setState(() {
      _selectedFilters = filters;
    });
    _updateActiveFilterChips();
    _filterStudents();
  }

  void _removeFilter(String filterType, String filterValue) {
    setState(() {
      if (_selectedFilters[filterType] != null) {
        _selectedFilters[filterType]!.remove(filterValue);
        if (_selectedFilters[filterType]!.isEmpty) {
          _selectedFilters.remove(filterType);
        }
      }
    });
    _updateActiveFilterChips();
    _filterStudents();
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterModalWidget(
        availableFilters: _availableFilters,
        selectedFilters: _selectedFilters,
        onFiltersChanged: _onFiltersChanged,
      ),
    );
  }

  void _toggleMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = !_isMultiSelectMode;
      if (!_isMultiSelectMode) {
        _selectedStudentIds.clear();
      }
    });
  }

  void _toggleStudentSelection(int studentId, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedStudentIds.add(studentId);
        if (!_isMultiSelectMode) {
          _isMultiSelectMode = true;
        }
      } else {
        _selectedStudentIds.remove(studentId);
        if (_selectedStudentIds.isEmpty) {
          _isMultiSelectMode = false;
        }
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedStudentIds.clear();
      _isMultiSelectMode = false;
    });
  }

  Future<void> _refreshStudents() async {
    // Simulate network refresh
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      // In real app, this would fetch fresh data
      _filteredStudents = List.from(_allStudents);
    });
  }

  void _navigateToStudentDetail(Map<String, dynamic> student) {
    if (!_isMultiSelectMode) {
      Navigator.pushNamed(context, '/student-detail', arguments: student);
    }
  }

  void _navigateToAddStudent() {
    Navigator.pushNamed(context, '/add-new-student');
  }

  void _recordPayment(Map<String, dynamic> student) {
    Navigator.pushNamed(context, '/record-payment', arguments: student);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final int totalActiveFilters = _activeFilterChips.length;

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('FeesMaster'),
        leading: IconButton(
          onPressed: () => Navigator.pushNamed(context, '/dashboard-overview'),
          icon: CustomIconWidget(
            iconName: 'dashboard',
            color: Colors.white,
            size: 6.w,
          ),
        ),
        actions: [
          if (_isMultiSelectMode)
            IconButton(
              onPressed: _clearSelection,
              icon: CustomIconWidget(
                iconName: 'close',
                color: Colors.white,
                size: 6.w,
              ),
            )
          else
            IconButton(
              onPressed: () => Navigator.pushNamed(context, '/admin-login'),
              icon: CustomIconWidget(
                iconName: 'account_circle',
                color: Colors.white,
                size: 6.w,
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Dashboard'),
            Tab(text: 'Students'),
            Tab(text: 'Payments'),
            Tab(text: 'Reports'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          SearchBarWidget(
            searchQuery: _searchQuery,
            onSearchChanged: _onSearchChanged,
            onFilterTap: _showFilterModal,
            hasActiveFilters: totalActiveFilters > 0,
            filterCount: totalActiveFilters,
            onVoiceSearch: () => _showSnackBar('Voice search not implemented'),
          ),

          // Active Filter Chips
          FilterChipsWidget(
            activeFilters: _activeFilterChips,
            onRemoveFilter: _removeFilter,
          ),

          // Student List
          Expanded(
            child: _filteredStudents.isEmpty
                ? _searchQuery.isNotEmpty || totalActiveFilters > 0
                    ? EmptyStateWidget(
                        title: 'No Students Found',
                        subtitle:
                            'Try adjusting your search or filters to find what you\'re looking for.',
                        buttonText: 'Clear Filters',
                        isSearchResult: true,
                        onButtonPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _selectedFilters.clear();
                            _activeFilterChips.clear();
                          });
                          _filterStudents();
                        },
                      )
                    : EmptyStateWidget(
                        title: 'No Students Yet',
                        subtitle:
                            'Start by adding your first student to begin managing fees and payments.',
                        buttonText: 'Add Student',
                        onButtonPressed: _navigateToAddStudent,
                      )
                : RefreshIndicator(
                    onRefresh: _refreshStudents,
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount: _filteredStudents.length,
                      itemBuilder: (context, index) {
                        final student = _filteredStudents[index];
                        final studentId = student['id'] as int;
                        final isSelected =
                            _selectedStudentIds.contains(studentId);

                        return StudentCardWidget(
                          student: student,
                          isSelected: isSelected,
                          isMultiSelectMode: _isMultiSelectMode,
                          onTap: () => _navigateToStudentDetail(student),
                          onSelectionChanged: (selected) =>
                              _toggleStudentSelection(studentId, selected),
                          onRecordPayment: () => _recordPayment(student),
                          onViewHistory: () => _showSnackBar(
                              'View history for ${student['name']}'),
                          onSendReminder: () => _showSnackBar(
                              'Reminder sent to ${student['name']}'),
                          onEdit: () =>
                              _showSnackBar('Edit ${student['name']}'),
                          onDelete: () {
                            setState(() {
                              _allStudents
                                  .removeWhere((s) => s['id'] == studentId);
                              _filterStudents();
                            });
                            _showSnackBar('${student['name']} deleted');
                          },
                        );
                      },
                    ),
                  ),
          ),

          // Multi-select actions
          if (_isMultiSelectMode)
            MultiSelectActionsWidget(
              selectedCount: _selectedStudentIds.length,
              onClearSelection: _clearSelection,
              onSendReminders: () {
                _showSnackBar(
                    'Reminders sent to ${_selectedStudentIds.length} students');
                _clearSelection();
              },
              onUpdateFeeStructure: () {
                _showSnackBar(
                    'Fee structure updated for ${_selectedStudentIds.length} students');
                _clearSelection();
              },
              onBulkDelete: () {
                setState(() {
                  _allStudents.removeWhere(
                      (student) => _selectedStudentIds.contains(student['id']));
                  _filterStudents();
                });
                _showSnackBar('${_selectedStudentIds.length} students deleted');
                _clearSelection();
              },
            ),
        ],
      ),
      floatingActionButton: _isMultiSelectMode
          ? null
          : FloatingActionButton(
              onPressed: _navigateToAddStudent,
              child: CustomIconWidget(
                iconName: 'add',
                color: Colors.white,
                size: 7.w,
              ),
            ),
    );
  }
}
