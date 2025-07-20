import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ParentContactCard extends StatelessWidget {
  final Map<String, dynamic> parentInfo;

  const ParentContactCard({
    Key? key,
    required this.parentInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'family_restroom',
                  color: Theme.of(context).colorScheme.primary,
                  size: 6.w,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Parent/Guardian Contact',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            Row(
              children: [
                Container(
                  width: 15.w,
                  height: 15.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(parentInfo['name'] as String? ?? 'Unknown'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        parentInfo['name'] as String? ?? 'Unknown Parent',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        parentInfo['relationship'] as String? ?? 'Guardian',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            _buildContactRow(
              context,
              'phone',
              'Phone',
              parentInfo['phone'] as String? ?? 'Not provided',
              onTap: () =>
                  _makePhoneCall(context, parentInfo['phone'] as String? ?? ''),
            ),
            SizedBox(height: 2.h),
            _buildContactRow(
              context,
              'email',
              'Email',
              parentInfo['email'] as String? ?? 'Not provided',
              onTap: () =>
                  _sendEmail(context, parentInfo['email'] as String? ?? ''),
            ),
            if (parentInfo['address'] != null) ...[
              SizedBox(height: 2.h),
              _buildContactRow(
                context,
                'location_on',
                'Address',
                parentInfo['address'] as String,
                onTap: () =>
                    _openMaps(context, parentInfo['address'] as String),
              ),
            ],
            SizedBox(height: 3.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _makePhoneCall(
                        context, parentInfo['phone'] as String? ?? ''),
                    icon: CustomIconWidget(
                      iconName: 'phone',
                      color: Theme.of(context).colorScheme.primary,
                      size: 5.w,
                    ),
                    label: Text('Call'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _sendMessage(
                        context, parentInfo['phone'] as String? ?? ''),
                    icon: CustomIconWidget(
                      iconName: 'message',
                      color: Theme.of(context).colorScheme.primary,
                      size: 5.w,
                    ),
                    label: Text('Message'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(
    BuildContext context,
    String iconName,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: iconName,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 5.w,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: onTap != null
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onTap != null)
            CustomIconWidget(
              iconName: 'arrow_forward_ios',
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 4.w,
            ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final words = name.trim().split(' ');
    if (words.isEmpty) return 'U';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  void _makePhoneCall(BuildContext context, String phoneNumber) {
    if (phoneNumber.isEmpty || phoneNumber == 'Not provided') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Phone number not available')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Call Parent'),
        content: Text('Do you want to call $phoneNumber?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // In a real app, this would use url_launcher to make the call
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calling $phoneNumber...')),
              );
            },
            child: Text('Call'),
          ),
        ],
      ),
    );
  }

  void _sendMessage(BuildContext context, String phoneNumber) {
    if (phoneNumber.isEmpty || phoneNumber == 'Not provided') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Phone number not available')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Send Message'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Send a message to $phoneNumber'),
            SizedBox(height: 2.h),
            TextField(
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Message sent to $phoneNumber')),
              );
            },
            child: Text('Send'),
          ),
        ],
      ),
    );
  }

  void _sendEmail(BuildContext context, String email) {
    if (email.isEmpty || email == 'Not provided') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email address not available')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening email to $email...')),
    );
  }

  void _openMaps(BuildContext context, String address) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening maps for $address...')),
    );
  }
}
