import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';

/// Feature grid widget showing app features
class FeatureGrid extends StatelessWidget {
  const FeatureGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final features = _getFeatures();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
          childAspectRatio: 0.7,
        ),
        itemCount: features.length,
        itemBuilder: (context, index) {
          final feature = features[index];
          return _FeatureItem(feature: feature);
        },
      ),
    );
  }

  List<_FeatureData> _getFeatures() {
    return [
      _FeatureData(
        icon: Icons.access_time,
        label: 'Absensi',
        color: const Color(0xFFFFB300),
        backgroundColor: const Color(0xFFFFFFFF),
        route: AppRoutes.activity,
      ),
      _FeatureData(
        icon: Icons.edit,
        label: 'Manajemen\nKehadiran',
        color: const Color(0xFF4CAF50),
        backgroundColor: const Color(0xFFFFFFFF),
        route: AppRoutes.attendanceManagement,
      ),
      _FeatureData(
        icon: Icons.people,
        label: 'Talent',
        color: const Color(0xFFE91E63),
        backgroundColor: const Color(0xFFFFFFFF),
        route: AppRoutes.talent,
      ),
      _FeatureData(
        icon: Icons.description,
        label: 'Report',
        color: const Color(0xFF2196F3),
        backgroundColor: const Color(0xFFFFFFFF),
        route: AppRoutes.report,
      ),
      _FeatureData(
        icon: Icons.grid_view,
        label: 'Spaces',
        color: const Color(0xFFFF9800),
        backgroundColor: const Color(0xFFFFFFFF),
        route: AppRoutes.spaces,
      ),
      _FeatureData(
        icon: Icons.schedule,
        label: 'Lembur',
        color: const Color(0xFF4CAF50),
        backgroundColor: const Color(0xFFFFFFFF),
        route: AppRoutes.overtime,
      ),
      _FeatureData(
        icon: Icons.attach_money,
        label: 'Reimburse',
        color: const Color(0xFFE91E63),
        backgroundColor: const Color(0xFFFFFFFF),
        route: AppRoutes.reimbursement,
      ),
      _FeatureData(
        icon: Icons.directions_car,
        label: 'Fasilitas',
        color: Colors.grey,
        backgroundColor: const Color(0xFFFFFFFF),
        route: AppRoutes.facilities,
      ),
      _FeatureData(
        icon: Icons.account_balance_wallet,
        label: 'Pinjaman',
        color: const Color(0xFF795548),
        backgroundColor: const Color(0xFFFFFFFF),
        route: AppRoutes.loan,
      ),
      _FeatureData(
        icon: Icons.money,
        label: 'Kasbon',
        color: const Color(0xFF4CAF50),
        backgroundColor: const Color(0xFFFFFFFF),
        route: AppRoutes.advance,
      ),
    ];
  }
}

class _FeatureItem extends StatelessWidget {
  final _FeatureData feature;

  const _FeatureItem({required this.feature});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(feature.route), // Use push to maintain navigation history
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: feature.backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              feature.icon,
              color: feature.color,
              size: 26,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            feature.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF757575),
              height: 1.2,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureData {
  final IconData icon;
  final String label;
  final Color color;
  final Color backgroundColor;
  final String route;

  _FeatureData({
    required this.icon,
    required this.label,
    required this.color,
    required this.backgroundColor,
    required this.route,
  });
}

