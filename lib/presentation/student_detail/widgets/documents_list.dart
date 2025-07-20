import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class DocumentsList extends StatelessWidget {
  final List<Map<String, dynamic>> documents;

  const DocumentsList({
    Key? key,
    required this.documents,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'folder_open',
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 15.w,
            ),
            SizedBox(height: 2.h),
            Text(
              'No Documents',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Student documents will appear here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ElevatedButton.icon(
              onPressed: () => _showAddDocumentOptions(context),
              icon: CustomIconWidget(
                iconName: 'add',
                color: Colors.white,
                size: 5.w,
              ),
              label: Text('Add Document'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Add Document Button
        Container(
          width: double.infinity,
          margin: EdgeInsets.all(4.w),
          child: OutlinedButton.icon(
            onPressed: () => _showAddDocumentOptions(context),
            icon: CustomIconWidget(
              iconName: 'add',
              color: Theme.of(context).colorScheme.primary,
              size: 5.w,
            ),
            label: Text('Add Document'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 2.h),
            ),
          ),
        ),
        // Documents List
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: documents.length,
            separatorBuilder: (context, index) => SizedBox(height: 1.h),
            itemBuilder: (context, index) {
              final document = documents[index];
              return _buildDocumentItem(context, document);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentItem(
      BuildContext context, Map<String, dynamic> document) {
    final String fileName = document['name'] as String? ?? 'Unknown Document';
    final String fileType = document['type'] as String? ?? 'unknown';
    final String fileSize = document['size'] as String? ?? '0 KB';
    final DateTime uploadDate = DateTime.parse(
        document['uploadDate'] as String? ?? DateTime.now().toIso8601String());

    return Card(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Row(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: _getFileTypeColor(fileType).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2.w),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: _getFileTypeIcon(fileType),
                  color: _getFileTypeColor(fileType),
                  size: 6.w,
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      Text(
                        fileType.toUpperCase(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _getFileTypeColor(fileType),
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      Text(
                        ' • $fileSize',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'Uploaded ${_formatDate(uploadDate)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) =>
                  _handleDocumentAction(context, document, value),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'visibility',
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 5.w,
                      ),
                      SizedBox(width: 2.w),
                      Text('View'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'download',
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'download',
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 5.w,
                      ),
                      SizedBox(width: 2.w),
                      Text('Download'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'share',
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 5.w,
                      ),
                      SizedBox(width: 2.w),
                      Text('Share'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'delete',
                        color: AppTheme.getErrorColor(
                            Theme.of(context).brightness == Brightness.light),
                        size: 5.w,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Delete',
                        style: TextStyle(
                          color: AppTheme.getErrorColor(
                              Theme.of(context).brightness == Brightness.light),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              child: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(1.w),
                ),
                child: CustomIconWidget(
                  iconName: 'more_vert',
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 5.w,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getFileTypeColor(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Colors.green;
      case 'txt':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getFileTypeIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return 'picture_as_pdf';
      case 'doc':
      case 'docx':
        return 'description';
      case 'jpg':
      case 'jpeg':
      case 'png':
        return 'image';
      case 'txt':
        return 'text_snippet';
      default:
        return 'insert_drive_file';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _showAddDocumentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(5.w)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(1.w),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'Add Document',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'camera_alt',
                color: Theme.of(context).colorScheme.primary,
                size: 6.w,
              ),
              title: Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                // Camera functionality
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'photo_library',
                color: Theme.of(context).colorScheme.primary,
                size: 6.w,
              ),
              title: Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                // Gallery functionality
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'folder',
                color: Theme.of(context).colorScheme.primary,
                size: 6.w,
              ),
              title: Text('Browse Files'),
              onTap: () {
                Navigator.pop(context);
                // File picker functionality
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _handleDocumentAction(
      BuildContext context, Map<String, dynamic> document, String action) {
    switch (action) {
      case 'view':
        // View document logic
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening ${document['name']}')),
        );
        break;
      case 'download':
        // Download document logic
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Downloading ${document['name']}')),
        );
        break;
      case 'share':
        // Share document logic
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sharing ${document['name']}')),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(context, document);
        break;
    }
  }

  void _showDeleteConfirmation(
      BuildContext context, Map<String, dynamic> document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Document'),
        content: Text(
            'Are you sure you want to delete "${document['name']}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${document['name']} deleted')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.getErrorColor(
                  Theme.of(context).brightness == Brightness.light),
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
