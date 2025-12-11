import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';

/// Animated Feature grid widget with interactive animations
class AnimatedFeatureGrid extends StatelessWidget {
  const AnimatedFeatureGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final features = _getFeatures();
    // Cache MediaQuery
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    
    // Responsive grid: adjust crossAxisCount based on screen width
    int crossAxisCount;
    double spacing;
    double aspectRatio;
    
    if (screenWidth > 600) {
      // Tablet/Large screens: 6 columns
      crossAxisCount = 6;
      spacing = 16;
      aspectRatio = 0.75;
    } else if (screenWidth > 400) {
      // Medium screens (most phones): 5 columns
      crossAxisCount = 5;
      spacing = 12;
      aspectRatio = 0.7;
    } else {
      // Small screens: 4 columns
      crossAxisCount = 4;
      spacing = 10;
      aspectRatio = 0.65;
    }

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          cacheExtent: 0, // No need to cache for static grid
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: 16,
            childAspectRatio: aspectRatio,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            // Staggered animation delay
            final delay = Duration(milliseconds: index * 50);
            return RepaintBoundary(
              child: AnimatedFeatureItem(
                feature: feature,
                delay: delay,
              ),
            );
          },
        ),
      ),
    );
  }

  List<_FeatureData> _getFeatures() {
    return [
      _FeatureData(
        icon: Icons.access_time,
        label: 'Absensi',
        color: const Color(0xFFFFB300),
        backgroundColor: Colors.white,
        route: AppRoutes.activity,
      ),
      _FeatureData(
        icon: Icons.edit,
        label: 'Manajemen\nKehadiran',
        color: const Color(0xFF4CAF50),
        backgroundColor: Colors.white,
        route: AppRoutes.attendanceManagement,
      ),
      _FeatureData(
        icon: Icons.people,
        label: 'Talent',
        color: const Color(0xFFE91E63),
        backgroundColor: Colors.white,
        route: AppRoutes.talent,
      ),
      _FeatureData(
        icon: Icons.description,
        label: 'Report',
        color: const Color(0xFF2196F3),
        backgroundColor: Colors.white,
        route: AppRoutes.report,
      ),
      _FeatureData(
        icon: Icons.grid_view,
        label: 'Spaces',
        color: const Color(0xFFFF9800),
        backgroundColor: Colors.white,
        route: AppRoutes.spaces,
      ),
      _FeatureData(
        icon: Icons.schedule,
        label: 'Lembur',
        color: const Color(0xFF4CAF50),
        backgroundColor: Colors.white,
        route: AppRoutes.overtime,
      ),
      _FeatureData(
        icon: Icons.attach_money,
        label: 'Reimburse',
        color: const Color(0xFFE91E63),
        backgroundColor: Colors.white,
        route: AppRoutes.reimbursement,
      ),
      _FeatureData(
        icon: Icons.directions_car,
        label: 'Fasilitas',
        color: Colors.grey,
        backgroundColor: Colors.white,
        route: AppRoutes.facilities,
      ),
      _FeatureData(
        icon: Icons.account_balance_wallet,
        label: 'Pinjaman',
        color: const Color(0xFF795548),
        backgroundColor: Colors.white,
        route: AppRoutes.loan,
      ),
      _FeatureData(
        icon: Icons.money,
        label: 'Kasbon',
        color: const Color(0xFF4CAF50),
        backgroundColor: Colors.white,
        route: AppRoutes.advance,
      ),
    ];
  }
}

/// Animated feature item with scale and haptic feedback
class AnimatedFeatureItem extends StatefulWidget {
  final _FeatureData feature;
  final Duration delay;

  const AnimatedFeatureItem({
    super.key,
    required this.feature,
    required this.delay,
  });

  @override
  State<AnimatedFeatureItem> createState() => _AnimatedFeatureItemState();
}

class _AnimatedFeatureItemState extends State<AnimatedFeatureItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    // Start animation with delay
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Cache MediaQuery
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    
    // Responsive sizing - use const values when possible
    final double iconSize;
    final double containerSize;
    final double fontSize;
    
    if (screenWidth > 600) {
      // Tablet/Large screens
      iconSize = 30;
      containerSize = 64;
      fontSize = 12;
    } else if (screenWidth > 400) {
      // Medium screens (most phones)
      iconSize = 26;
      containerSize = 56;
      fontSize = 11;
    } else {
      // Small screens
      iconSize = 22;
      containerSize = 48;
      fontSize = 10;
    }
    
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTapDown: (_) {
            setState(() => _isPressed = true);
            HapticFeedback.lightImpact();
          },
          onTapUp: (_) {
            setState(() => _isPressed = false);
          },
          onTapCancel: () {
            setState(() => _isPressed = false);
          },
          onTap: () {
            HapticFeedback.mediumImpact();
            // Use push instead of go to maintain navigation history
            // This allows back button to work properly
            context.push(widget.feature.route);
          },
          child: AnimatedScale(
            scale: _isPressed ? 0.85 : 1.0,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: containerSize,
                  height: containerSize,
                  decoration: BoxDecoration(
                    color: widget.feature.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    // No shadow - clean white background only
                  ),
                  child: Icon(
                    widget.feature.icon,
                    color: widget.feature.color,
                    size: iconSize,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.feature.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: fontSize,
                    color: const Color(0xFF757575),
                    height: 1.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
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

