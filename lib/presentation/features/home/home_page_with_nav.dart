import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/scheduler.dart';

import '../../../core/widgets/notification_badge.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/task/task_bloc.dart';
import '../activity/pages/activity_page_refactored.dart';
import '../tasks/pages/tasks_page_refactored.dart';
import '../training/pages/training_page_refactored.dart';
import '../profile/pages/profile_page_refactored.dart';
import 'home_page_refactored.dart';

/// KeepAlive wrapper to prevent page rebuilds when swiping
class KeepAlivePage extends StatefulWidget {
  final Widget child;

  const KeepAlivePage({
    super.key,
    required this.child,
  });

  @override
  State<KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Keep page alive to prevent rebuilds

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return RepaintBoundary(
      child: widget.child,
    );
  }
}

/// Home page with bottom navigation and swipe support
class HomePageWithNav extends StatefulWidget {
  const HomePageWithNav({super.key});

  @override
  State<HomePageWithNav> createState() => _HomePageWithNavState();
}

class _HomePageWithNavState extends State<HomePageWithNav> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const PageScrollPhysics(), // Smooth physics for better swipe
        onPageChanged: (index) {
          // Only update if actually changed to prevent unnecessary rebuilds
          if (_currentIndex != index) {
            setState(() => _currentIndex = index);
          }
        },
        // Cache pages to prevent rebuild on swipe
        children: [
          // Use keys to maintain state and prevent rebuilds
          const KeepAlivePage(key: PageStorageKey('home'), child: HomePageRefactored()),
          const KeepAlivePage(key: PageStorageKey('activity'), child: ActivityPageRefactored()),
          const KeepAlivePage(key: PageStorageKey('tasks'), child: TasksPageRefactored()),
          const KeepAlivePage(key: PageStorageKey('training'), child: TrainingPageRefactored()),
          const KeepAlivePage(key: PageStorageKey('profile'), child: ProfilePageRefactored()),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildBottomNavigation() {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) {
        // Only rebuild when user data changes, not on every state change
        if (previous is AuthAuthenticated && current is AuthAuthenticated) {
          return previous.user.profilePhotoUrl != current.user.profilePhotoUrl ||
                 previous.user.name != current.user.name;
        }
        return previous.runtimeType != current.runtimeType;
      },
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _currentIndex,
              onTap: (index) {
                if (_currentIndex != index) {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 250), // Slightly faster
                    curve: Curves.easeOutCubic, // Smoother curve
                  );
                  // Update index immediately for responsive UI
                  setState(() => _currentIndex = index);
                }
                // HapticFeedback removed for better performance
              },
              selectedItemColor: const Color(0xFF4285F4), // Google Blue
              unselectedItemColor: const Color(0xFF9E9E9E), // Light grey
              selectedFontSize: 12,
              unselectedFontSize: 12,
              iconSize: 26,
              elevation: 0,
              backgroundColor: Colors.white,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
              items: [
                BottomNavigationBarItem(
                  icon: _buildNavIcon(0, Icons.home_outlined, Icons.home),
                  label: 'Beranda',
                ),
                BottomNavigationBarItem(
                  icon: _buildNavIcon(1, Icons.check_circle_outline, Icons.check_circle),
                  label: 'Aktivitas',
                ),
                BottomNavigationBarItem(
                  icon: _buildNavIconWithBadge(
                    2,
                    Icons.assignment_outlined,
                    Icons.assignment,
                    _getTaskCount(context),
                  ),
                  label: 'Tugas',
                ),
                BottomNavigationBarItem(
                  icon: _buildNavIconWithBadge(
                    3,
                    Icons.menu_book_outlined,
                    Icons.menu_book,
                    3, // Demo: 3 new trainings
                  ),
                  label: 'Pelatihan',
                ),
                BottomNavigationBarItem(
                  icon: _buildNavIcon(
                    4,
                    _buildProfileIcon(user, false),
                    _buildProfileIcon(user, true),
                  ),
                  label: 'Profil',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavIcon(int index, dynamic unselectedIcon, dynamic selectedIcon) {
    final isSelected = _currentIndex == index;

    // Handle both IconData and Widget types
    Widget iconWidget;
    if (unselectedIcon is IconData) {
      iconWidget = Icon(
        isSelected ? selectedIcon as IconData : unselectedIcon,
        color: isSelected ? const Color(0xFF4285F4) : const Color(0xFF9E9E9E),
        size: 26,
      );
    } else {
      iconWidget = isSelected ? selectedIcon as Widget : unselectedIcon as Widget;
    }

    // Use simpler animation or remove for better performance
    return RepaintBoundary(
      child: AnimatedScale(
        scale: isSelected ? 1.05 : 1.0, // Reduced scale for less animation overhead
        duration: const Duration(milliseconds: 150), // Faster animation
        curve: Curves.easeOut, // Simpler curve
        child: iconWidget,
      ),
    );
  }

  Widget _buildNavIconWithBadge(
    int index,
    IconData unselectedIcon,
    IconData selectedIcon,
    int badgeCount,
  ) {
    final isSelected = _currentIndex == index;

    return RepaintBoundary(
      child: AnimatedScale(
        scale: isSelected ? 1.05 : 1.0, // Reduced scale
        duration: const Duration(milliseconds: 150), // Faster animation
        curve: Curves.easeOut, // Simpler curve
        child: NotificationBadge(
          count: badgeCount,
          child: Icon(
            isSelected ? selectedIcon : unselectedIcon,
            color: isSelected ? const Color(0xFF4285F4) : const Color(0xFF9E9E9E),
            size: 26,
          ),
        ),
      ),
    );
  }

  int _getTaskCount(BuildContext context) {
    // Use select instead of watch to prevent rebuilds
    final taskState = context.select<TaskBloc, TaskState>((bloc) => bloc.state);
    if (taskState is TaskLoaded) {
      // Count pending tasks
      return taskState.tasks.length; // Simplified - count all tasks
    }
    return 0;
  }

  Widget _buildProfileIcon(dynamic user, bool isSelected) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: isSelected
            ? Border.all(color: const Color(0xFF4285F4), width: 2.5)
            : Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
      ),
      child: ClipOval(
        child: (user != null &&
                user.profilePhotoUrl != null &&
                user.profilePhotoUrl!.isNotEmpty)
            ? Image.network(
                user.profilePhotoUrl!,
                key: ValueKey('nav_profile_${user.profilePhotoUrl}'), // Force rebuild when URL changes
                width: 28, // Explicit width - SQUARE
                height: 28, // Explicit height - SQUARE
                fit: BoxFit.cover, // Cover maintains aspect ratio
                cacheWidth: 56, // Optimize: 28px * 2 for retina
                cacheHeight: 56, // SAME ratio to prevent distortion
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: isSelected ? const Color(0xFFE3F2FD) : const Color(0xFFF5F5F5),
                    child: Icon(
                      Icons.person,
                      size: 18,
                      color: isSelected ? const Color(0xFF4285F4) : const Color(0xFF9E9E9E),
                    ),
                  );
                },
              )
            : Container(
                color: isSelected ? const Color(0xFFE3F2FD) : const Color(0xFFF5F5F5),
                child: Icon(
                  Icons.person,
                  size: 18,
                  color: isSelected ? const Color(0xFF4285F4) : const Color(0xFF9E9E9E),
                ),
              ),
      ),
    );
  }
}

