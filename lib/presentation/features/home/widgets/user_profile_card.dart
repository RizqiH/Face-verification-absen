import 'package:flutter/material.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../domain/entities/user.dart';

/// User profile card widget for home page
/// Shows user info with current date and time
class UserProfileCard extends StatelessWidget {
  final User user;

  const UserProfileCard({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          _buildProfileImage(),
          const SizedBox(width: 12),
          Expanded(
            child: _buildUserInfo(),
          ),
          _buildDateTime(now),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: ClipOval(
        clipBehavior: Clip.antiAlias,
        child: (user.profilePhotoUrl != null && user.profilePhotoUrl!.isNotEmpty)
            ? Image.network(
                user.profilePhotoUrl!,
                key: ValueKey('home_profile_${user.profilePhotoUrl}'), // Force rebuild when URL changes
                width: 64, // Explicit width - SQUARE
                height: 64, // Explicit height - SQUARE
                fit: BoxFit.cover, // Cover maintains aspect ratio, crops if needed
                cacheWidth: 128, // Optimize: 64px * 2 for retina
                cacheHeight: 128, // SAME ratio to prevent distortion
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, size: 40, color: Colors.grey),
                  );
                },
              )
            : Container(
                width: 64,
                height: 64,
                color: Colors.grey[200],
                child: const Icon(Icons.person, size: 40, color: Colors.grey),
              ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.position,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF757575),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTime(DateTime now) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          DateFormatter.formatDate(now),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${DateFormatter.formatTime(now)} WIB',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF757575),
          ),
        ),
      ],
    );
  }
}

