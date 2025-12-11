import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../widgets/shimmer_loading.dart';

/// Spaces Page - Meeting room & workspace management
class SpacesPage extends StatelessWidget {
  const SpacesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            context.go(AppRoutes.home);
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
        title: const Text('Spaces'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Book new space
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (context, index) {
          return _buildSpaceCard(index);
        },
      ),
      ),
    );
  }

  Widget _buildSpaceCard(int index) {
    final spaces = [
      {'name': 'Meeting Room A', 'capacity': '10', 'status': 'Available'},
      {'name': 'Meeting Room B', 'capacity': '6', 'status': 'Booked'},
      {'name': 'Conference Hall', 'capacity': '50', 'status': 'Available'},
      {'name': 'Discussion Room 1', 'capacity': '4', 'status': 'Available'},
      {'name': 'Hot Desk Area', 'capacity': '20', 'status': 'Available'},
      {'name': 'Creative Studio', 'capacity': '15', 'status': 'Booked'},
    ];

    final space = spaces[index % spaces.length];
    final isAvailable = space['status'] == 'Available';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: (isAvailable ? Colors.green : Colors.orange).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.meeting_room,
              size: 32,
              color: isAvailable ? Colors.green : Colors.orange,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  space['name']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.people, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${space['capacity']} orang',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isAvailable ? Colors.green[50] : Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              space['status']!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isAvailable ? Colors.green[700] : Colors.orange[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

