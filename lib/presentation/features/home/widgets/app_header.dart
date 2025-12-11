import 'package:flutter/material.dart';
import '../../../../core/widgets/notification_badge.dart';

/// App header widget for home page
class AppHeader extends StatelessWidget {
  final String companyName;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onNotificationPressed;
  final int notificationCount;

  const AppHeader({
    super.key,
    this.companyName = 'PT. Classik Creactive',
    this.onSearchPressed,
    this.onNotificationPressed,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCompanyName(),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildCompanyName() {
    return Row(
      children: [
        Text(
          companyName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2196F3),
          ),
        ),
        const SizedBox(width: 4),
        const Icon(
          Icons.arrow_drop_down,
          color: Color(0xFF2196F3),
          size: 20,
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.search, size: 24, color: Colors.black87),
          onPressed: onSearchPressed ?? () {},
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: NotificationBadge(
                        count: notificationCount,
                        badgeColor: Colors.red,
                        child: const Icon(
                          Icons.notifications_outlined,
                          size: 24,
                          color: Colors.black87,
                        ),
                      ),
                      onPressed: onNotificationPressed ?? () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
      ],
    );
  }
}

