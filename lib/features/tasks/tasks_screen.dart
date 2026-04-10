import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/providers/app_provider.dart';
import '../../shared/models/task_model.dart';
import '../../core/theme/app_theme.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _statuses = ['all', 'backlog', 'todo', 'in_progress', 'in_review', 'done'];
  final _statusLabels = ['All', 'Backlog', 'To Do', 'In Progress', 'In Review', 'Done'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statuses.length, vsync: this);
    Future.microtask(() => context.read<AppProvider>().loadTasks());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.grey,
            indicatorColor: AppTheme.primary,
            tabs: _statusLabels.map((l) => Tab(text: l)).toList(),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _statuses.map((status) => _TaskList(status: status)).toList(),
          ),
        ),
      ],
    );
  }
}

class _TaskList extends StatelessWidget {
  final String status;

  const _TaskList({required this.status});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        if (provider.tasks.isEmpty && provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final tasks = status == 'all'
            ? provider.tasks
            : provider.tasks.where((t) => t.status == status).toList();

        if (tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.task_alt, size: 64, color: AppTheme.grey),
                const SizedBox(height: 16),
                Text('No ${status == 'all' ? '' : status.replaceAll('_', ' ')} tasks'),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadTasks(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) => _TaskCard(task: tasks[index]),
          ),
        );
      },
    );
  }
}

class _TaskCard extends StatelessWidget {
  final TaskModel task;

  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showTaskDialog(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  _PriorityBadge(priority: task.priority),
                ],
              ),
              if (task.description != null) ...[
                const SizedBox(height: 8),
                Text(task.description!, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: AppTheme.grey)),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  if (task.agent != null) ...[
                    Chip(label: Text(task.agent!, style: const TextStyle(fontSize: 11))),
                    const SizedBox(width: 8),
                  ],
                  _StatusBadge(status: task.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTaskDialog(BuildContext context) {
    final provider = context.read<AppProvider>();
    final statuses = ['backlog', 'todo', 'in_progress', 'in_review', 'done'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            if (task.description != null) ...[
              const SizedBox(height: 8),
              Text(task.description!),
            ],
            const SizedBox(height: 24),
            const Text('Change Status', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: statuses.map((s) {
                final isSelected = s == task.status;
                return ChoiceChip(
                  label: Text(s.replaceAll('_', ' ').toUpperCase()),
                  selected: isSelected,
                  onSelected: (_) async {
                    Navigator.pop(ctx);
                    await provider.updateTaskStatus(task.id!, s);
                  },
                  selectedColor: AppTheme.primary.withOpacity(0.2),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final String priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (priority) {
      case 'high': color = AppTheme.danger; break;
      case 'medium': color = AppTheme.warning; break;
      default: color = AppTheme.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(priority.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'done': color = AppTheme.success; break;
      case 'in_progress': color = AppTheme.primary; break;
      case 'in_review': color = AppTheme.warning; break;
      case 'todo': color = AppTheme.grey; break;
      default: color = AppTheme.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status.replaceAll('_', ' '), style: TextStyle(color: color, fontSize: 11)),
    );
  }
}
