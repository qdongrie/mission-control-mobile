import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/providers/app_provider.dart';
import '../../core/theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AppProvider>().loadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.activeAgentsList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadDashboard(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Stats Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _StatCard(
                    icon: Icons.pending_actions,
                    label: 'Approvals',
                    value: '${provider.pendingApprovals}',
                    color: AppTheme.warning,
                    onTap: () => DefaultTabController.of(context).animateTo(1),
                  ),
                  _StatCard(
                    icon: Icons.smart_toy,
                    label: 'Agents Active',
                    value: '${provider.activeAgents}',
                    color: AppTheme.success,
                    onTap: () => DefaultTabController.of(context).animateTo(0),
                  ),
                  _StatCard(
                    icon: Icons.task_alt,
                    label: 'Tasks Todo',
                    value: '${provider.todoTasks}',
                    color: AppTheme.primary,
                    onTap: () => DefaultTabController.of(context).animateTo(2),
                  ),
                  _StatCard(
                    icon: Icons.people,
                    label: 'New Leads',
                    value: '${provider.newLeads}',
                    color: AppTheme.danger,
                    onTap: () => DefaultTabController.of(context).animateTo(3),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Active Agents
              if (provider.activeAgentsList.isNotEmpty) ...[
                _SectionHeader(title: 'Active Agents', icon: Icons.smart_toy),
                const SizedBox(height: 8),
                ...provider.activeAgentsList.map((agent) => _AgentCard(agent: agent)),
                const SizedBox(height: 24),
              ],

              // Recent Activity
              _SectionHeader(title: 'Recent Activity', icon: Icons.history),
              const SizedBox(height: 8),
              if (provider.memoryEvents.isEmpty)
                const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No recent activity')))
              else
                ...provider.memoryEvents.take(10).map((event) => _ActivityItem(event: event)),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.grey),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _AgentCard extends StatelessWidget {
  final dynamic agent;

  const _AgentCard({required this.agent});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.success.withOpacity(0.2),
          child: const Icon(Icons.smart_toy, color: AppTheme.success, size: 20),
        ),
        title: Text(agent.agent, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(agent.taskName, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Chip(
          label: Text(agent.durationString, style: const TextStyle(fontSize: 12)),
          backgroundColor: AppTheme.success.withOpacity(0.1),
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final Map<String, dynamic> event;

  const _ActivityItem({required this.event});

  @override
  Widget build(BuildContext context) {
    final timestamp = event['timestamp'] ?? '';
    final agent = event['agent'] ?? '';
    final action = event['action'] ?? '';
    final notes = event['notes'] ?? '';

    return Card(
      child: ListTile(
        dense: true,
        leading: const Icon(Icons.circle, size: 8, color: AppTheme.primary),
        title: Text('$agent: $action', style: const TextStyle(fontSize: 14)),
        subtitle: notes.isNotEmpty ? Text(notes, maxLines: 1, overflow: TextOverflow.ellipsis) : null,
        trailing: Text(
          timestamp.toString().split(' ').last.split('.').first,
          style: const TextStyle(fontSize: 11, color: AppTheme.grey),
        ),
      ),
    );
  }
}
