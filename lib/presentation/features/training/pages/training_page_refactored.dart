import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../bloc/training/training_bloc.dart';
import '../../../widgets/shimmer_loading.dart';
import '../widgets/training_category_filter.dart';
import '../widgets/training_list_item.dart';

/// Refactored Training Page
class TrainingPageRefactored extends StatefulWidget {
  const TrainingPageRefactored({super.key});

  @override
  State<TrainingPageRefactored> createState() => _TrainingPageRefactoredState();
}

class _TrainingPageRefactoredState extends State<TrainingPageRefactored> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'all';
  String _searchQuery = '';
  
  // Cache filtered results to avoid recomputation
  List<dynamic>? _cachedFilteredTrainings;
  String? _lastCategoryFilter;
  String? _lastSearchQuery;

  @override
  void initState() {
    super.initState();
    // Load trainings
    context.read<TrainingBloc>().add(const GetTrainingsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Cache MediaQuery to avoid repeated calls
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;
    final screenWidth = mediaQuery.size.width;
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // Prevent back button from exiting app, navigate within app instead
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            // Navigate to home if can't pop
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text('Pelatihan'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        body: Column(
        children: [
          _buildSearchBar(),
          TrainingCategoryFilter(
            selectedCategory: _selectedCategory,
            onCategoryChanged: (category) {
              setState(() => _selectedCategory = category);
            },
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              child: BlocBuilder<TrainingBloc, TrainingState>(
                buildWhen: (previous, current) {
                  // Only rebuild when state type changes or trainings actually change
                  if (previous is TrainingLoaded && current is TrainingLoaded) {
                    return previous.trainings != current.trainings;
                  }
                  return previous.runtimeType != current.runtimeType;
                },
                builder: (context, state) {
                  if (state is TrainingLoading) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 80 + bottomPadding),
                      child: const ShimmerList(itemCount: 3, itemHeight: 250),
                    );
                  }

                  if (state is TrainingError) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 80 + bottomPadding),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: _buildError(state.message),
                      ),
                    );
                  }

                  if (state is TrainingLoaded) {
                    final filteredTrainings = _getFilteredTrainings(state.trainings);

                    if (filteredTrainings.isEmpty) {
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 80 + bottomPadding),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: _buildEmptyState(),
                        ),
                      );
                    }

                    return RepaintBoundary(
                      child: ListView.builder(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 80 + bottomPadding),
                        // Performance optimizations
                        cacheExtent: 500, // Pre-cache 500px worth of items
                        addAutomaticKeepAlives: false, // Don't keep items alive when off-screen
                        addRepaintBoundaries: true, // Isolate repaints
                        itemExtent: 250, // Fixed height for better performance
                        itemCount: filteredTrainings.length,
                        itemBuilder: (context, index) {
                          return RepaintBoundary(
                            child: TrainingListItem(training: filteredTrainings[index]),
                          );
                        },
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 80 + bottomPadding),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: _buildEmptyState(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari pelatihan...',
          prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) {
          // Debounce search to avoid too many rebuilds
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted && _searchController.text == value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            }
          });
        },
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<TrainingBloc>().add(const GetTrainingsEvent());
            },
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyState(
      icon: Icons.school_outlined,
      title: 'Belum Ada Pelatihan',
      subtitle: 'Program pelatihan akan tersedia segera',
      actionText: 'Muat Ulang',
      onActionPressed: () {
        context.read<TrainingBloc>().add(const GetTrainingsEvent());
      },
    );
  }

  List<dynamic> _getFilteredTrainings(List<dynamic> trainings) {
    // Use cached result if filters haven't changed
    if (_cachedFilteredTrainings != null &&
        _lastCategoryFilter == _selectedCategory &&
        _lastSearchQuery == _searchQuery) {
      return _cachedFilteredTrainings!;
    }

    var filtered = trainings;

    // Filter by category
    if (_selectedCategory != 'all') {
      // TODO: Implement category filtering when backend supports it
    }

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((training) {
        final title = training.title?.toString().toLowerCase() ?? '';
        final description = training.description?.toString().toLowerCase() ?? '';
        return title.contains(_searchQuery) || description.contains(_searchQuery);
      }).toList();
    }

    // Cache the result
    _cachedFilteredTrainings = filtered;
    _lastCategoryFilter = _selectedCategory;
    _lastSearchQuery = _searchQuery;

    return filtered;
  }
  
  List<dynamic> _filterTrainings(List<dynamic> trainings) {
    return _getFilteredTrainings(trainings);
  }

  Future<void> _handleRefresh() async {
    context.read<TrainingBloc>().add(const GetTrainingsEvent());
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

