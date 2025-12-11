import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../bloc/task/task_bloc.dart';
import '../../../widgets/shimmer_loading.dart';
import '../widgets/task_filter.dart';
import '../widgets/task_list_item.dart';

/// Refactored Tasks Page
class TasksPageRefactored extends StatefulWidget {
  const TasksPageRefactored({super.key});

  @override
  State<TasksPageRefactored> createState() => _TasksPageRefactoredState();
}

class _TasksPageRefactoredState extends State<TasksPageRefactored> {
  String _selectedFilter = 'all';
  
  // Cache filtered results
  List<dynamic>? _cachedFilteredTasks;
  String? _lastFilter;

  @override
  void initState() {
    super.initState();
    // Load tasks
    context.read<TaskBloc>().add(const GetTasksEvent());
  }

  @override
  Widget build(BuildContext context) {
    // Cache MediaQuery
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Tugas'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          TaskFilter(
            selectedFilter: _selectedFilter,
            onFilterChanged: (filter) {
              setState(() => _selectedFilter = filter);
            },
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              child: BlocBuilder<TaskBloc, TaskState>(
                buildWhen: (previous, current) {
                  // Only rebuild when state type changes or tasks actually change
                  if (previous is TaskLoaded && current is TaskLoaded) {
                    return previous.tasks != current.tasks;
                  }
                  return previous.runtimeType != current.runtimeType;
                },
                builder: (context, state) {
                  if (state is TaskLoading) {
                    return const ShimmerList(itemCount: 4, itemHeight: 100);
                  }

                  if (state is TaskError) {
                    return _buildError(state.message);
                  }

                  if (state is TaskLoaded) {
                    final filteredTasks = _getFilteredTasks(state.tasks);

                    if (filteredTasks.isEmpty) {
                      return _buildEmptyState();
                    }

                    return RepaintBoundary(
                      child: ListView.builder(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 80 + bottomPadding),
                        // Performance optimizations
                        cacheExtent: 500,
                        addAutomaticKeepAlives: false,
                        addRepaintBoundaries: true,
                        itemExtent: 100, // Fixed height for better performance
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) {
                          return RepaintBoundary(
                            child: TaskListItem(task: filteredTasks[index]),
                          );
                        },
                      ),
                    );
                  }

                  return _buildEmptyState();
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to create task page
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fitur tambah tugas segera hadir')),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
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
            onPressed: () => context.read<TaskBloc>().add(const GetTasksEvent()),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyState(
      icon: Icons.assignment_outlined,
      title: 'Belum Ada Tugas',
      subtitle: 'Tugas yang diberikan akan muncul di sini',
      actionText: 'Muat Ulang',
      onActionPressed: () {
        context.read<TaskBloc>().add(const GetTasksEvent());
      },
    );
  }

  List<dynamic> _getFilteredTasks(List<dynamic> tasks) {
    // Use cached result if filter hasn't changed
    if (_cachedFilteredTasks != null && _lastFilter == _selectedFilter) {
      return _cachedFilteredTasks!;
    }

    List<dynamic> filtered;
    if (_selectedFilter == 'all') {
      filtered = tasks;
    } else {
      // TODO: Implement actual filtering based on task status
      filtered = tasks;
    }

    // Cache the result
    _cachedFilteredTasks = filtered;
    _lastFilter = _selectedFilter;

    return filtered;
  }
  
  List<dynamic> _filterTasks(List<dynamic> tasks) {
    return _getFilteredTasks(tasks);
  }

  Future<void> _handleRefresh() async {
    context.read<TaskBloc>().add(const GetTasksEvent());
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

