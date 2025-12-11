import 'package:flutter/material.dart';

/// Parallax scrolling header
class ParallaxHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double maxHeight;
  final double minHeight;
  final Color? backgroundColor;
  final Widget? backgroundImage;

  const ParallaxHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.maxHeight = 200,
    this.minHeight = 80,
    this.backgroundColor,
    this.backgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: maxHeight,
      floating: false,
      pinned: true,
      backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final percent = (constraints.maxHeight - minHeight) / (maxHeight - minHeight);
          final opacity = percent.clamp(0.0, 1.0);

          return FlexibleSpaceBar(
            title: AnimatedOpacity(
              opacity: 1.0 - opacity,
              duration: const Duration(milliseconds: 100),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                if (backgroundImage != null) backgroundImage!,
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3 * opacity),
                        Colors.black.withOpacity(0.7 * opacity),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: 16,
                  right: 16,
                  child: AnimatedOpacity(
                    opacity: opacity,
                    duration: const Duration(milliseconds: 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            subtitle!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

