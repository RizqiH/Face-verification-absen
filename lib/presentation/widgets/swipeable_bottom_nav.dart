import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Swipeable Bottom Navigation Bar
/// Supports swipe left/right to change tabs
class SwipeableBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onPageChanged;
  final List<Widget> pages;
  final List<BottomNavigationBarItem> items;

  const SwipeableBottomNav({
    super.key,
    required this.currentIndex,
    required this.onPageChanged,
    required this.pages,
    required this.items,
  });

  @override
  State<SwipeableBottomNav> createState() => _SwipeableBottomNavState();
}

class _SwipeableBottomNavState extends State<SwipeableBottomNav> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.currentIndex);
  }

  @override
  void didUpdateWidget(SwipeableBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _pageController.animateToPage(
        widget.currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              HapticFeedback.lightImpact();
              widget.onPageChanged(index);
            },
            children: widget.pages,
          ),
        ),
        _buildBottomNavBar(),
      ],
    );
  }

  Widget _buildBottomNavBar() {
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
          currentIndex: widget.currentIndex,
          onTap: (index) {
            HapticFeedback.selectionClick();
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
            widget.onPageChanged(index);
          },
          selectedItemColor: const Color(0xFF2196F3),
          unselectedItemColor: const Color(0xFF757575),
          selectedFontSize: 11,
          unselectedFontSize: 11,
          iconSize: 24,
          elevation: 0,
          backgroundColor: Colors.white,
          items: widget.items,
        ),
      ),
    );
  }
}

