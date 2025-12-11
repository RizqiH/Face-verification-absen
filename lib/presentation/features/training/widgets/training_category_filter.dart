import 'package:flutter/material.dart';

/// Training category filter widget
class TrainingCategoryFilter extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategoryChanged;

  const TrainingCategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildCategoryChip('Semua', 'all'),
          const SizedBox(width: 12), // Increased spacing
          _buildCategoryChip('Teknologi', 'technology'),
          const SizedBox(width: 12), // Increased spacing
          _buildCategoryChip('Manajemen', 'management'),
          const SizedBox(width: 12), // Increased spacing
          _buildCategoryChip('Soft Skills', 'soft_skills'),
          const SizedBox(width: 12), // Increased spacing
          _buildCategoryChip('Leadership', 'leadership'),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, String value) {
    final isSelected = selectedCategory == value;
    return GestureDetector(
      onTap: () => onCategoryChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Increased padding
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2196F3) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF2196F3) : Colors.grey[300]!,
            width: 1.5, // Slightly thicker border
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 14, // Explicit font size
            ),
          ),
        ),
      ),
    );
  }
}

