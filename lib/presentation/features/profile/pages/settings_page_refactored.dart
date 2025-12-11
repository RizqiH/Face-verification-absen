import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';

/// Refactored Settings Page
class SettingsPageRefactored extends StatefulWidget {
  const SettingsPageRefactored({super.key});

  @override
  State<SettingsPageRefactored> createState() => _SettingsPageRefactoredState();
}

class _SettingsPageRefactoredState extends State<SettingsPageRefactored> {
  bool _notificationsEnabled = true;
  bool _faceIdEnabled = false;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            Navigator.of(context).pop();
          }
        },
        child: ListView(
          children: [
          _buildSectionHeader('Notifikasi'),
          _buildSettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifikasi Push',
            subtitle: 'Terima notifikasi untuk aktivitas penting',
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() => _notificationsEnabled = value);
              },
              activeColor: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('Keamanan'),
          _buildSettingsTile(
            icon: Icons.fingerprint,
            title: 'Biometric Login',
            subtitle: 'Gunakan Face ID / Fingerprint untuk login',
            trailing: Switch(
              value: _faceIdEnabled,
              onChanged: (value) {
                setState(() => _faceIdEnabled = value);
              },
              activeColor: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('Tampilan'),
          _buildSettingsTile(
            icon: Icons.dark_mode_outlined,
            title: 'Mode Gelap',
            subtitle: 'Aktifkan tema gelap',
            trailing: Switch(
              value: _darkModeEnabled,
              onChanged: (value) {
                setState(() => _darkModeEnabled = value);
              },
              activeColor: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('Lainnya'),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: 'Tentang Aplikasi',
            subtitle: 'Versi 1.0.0',
            onTap: () {
              _showAboutDialog();
            },
          ),
          _buildSettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Kebijakan Privasi',
            subtitle: 'Baca kebijakan privasi kami',
            onTap: () {
              // TODO: Navigate to privacy policy
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.white),
                      SizedBox(width: 12),
                      Expanded(child: Text('Kebijakan Privasi akan segera tersedia')),
                    ],
                  ),
                  backgroundColor: AppTheme.primaryColor,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
          ),
          _buildSettingsTile(
            icon: Icons.description_outlined,
            title: 'Syarat & Ketentuan',
            subtitle: 'Baca syarat dan ketentuan',
            onTap: () {
              // TODO: Navigate to terms
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.white),
                      SizedBox(width: 12),
                      Expanded(child: Text('Syarat & Ketentuan akan segera tersedia')),
                    ],
                  ),
                  backgroundColor: AppTheme.primaryColor,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        trailing: trailing ??
            (onTap != null
                ? Icon(Icons.chevron_right, color: Colors.grey[400])
                : null),
        onTap: onTap,
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Face Verification Attendance',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.face,
          size: 32,
          color: AppTheme.primaryColor,
        ),
      ),
      children: [
        const Text(
          'Aplikasi absensi dengan verifikasi wajah untuk PT. Classik Creactive',
        ),
      ],
    );
  }
}

