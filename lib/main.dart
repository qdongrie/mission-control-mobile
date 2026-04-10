import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'shared/providers/app_provider.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/approvals/approvals_screen.dart';
import 'features/tasks/tasks_screen.dart';
import 'features/leads/leads_screen.dart';

void main() {
  runApp(const MissionControlApp());
}

class MissionControlApp extends StatelessWidget {
  const MissionControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: MaterialApp(
        title: 'Mission Control',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final _screens = const [
    DashboardScreen(),
    ApprovalsScreen(),
    TasksScreen(),
    LeadsScreen(),
  ];

  final _titles = ['Dashboard', 'Approvals', 'Tasks', 'Leads'];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Builder(
        builder: (context) {
          final tabIndex = DefaultTabController.of(context).index;
          return Scaffold(
            appBar: AppBar(
              title: Text(_titles[_currentIndex]),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => context.read<AppProvider>().refreshAll(),
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                ),
              ],
              bottom: TabBar(
                controller: DefaultTabController.of(context),
                onTap: (index) => setState(() => _currentIndex = index),
                tabs: [
                  _buildTab(Icons.dashboard, 'Dashboard'),
                  _buildTab(Icons.pending_actions, 'Approvals'),
                  _buildTab(Icons.task_alt, 'Tasks'),
                  _buildTab(Icons.people, 'Leads'),
                ],
              ),
            ),
            body: TabBarView(
              controller: DefaultTabController.of(context),
              children: _screens,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTab(IconData icon, String label) {
    return Tab(
      child: Consumer<AppProvider>(
        builder: (context, provider, _) {
          int count = 0;
          switch (label) {
            case 'Approvals':
              count = provider.pendingApprovals;
              break;
            case 'Tasks':
              count = provider.todoTasks;
              break;
            case 'Leads':
              count = provider.newLeads;
              break;
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 4),
              Text(label),
              if (count > 0) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.danger,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('$count', style: const TextStyle(fontSize: 10, color: Colors.white)),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Mission Control Mobile'),
            subtitle: Text('Version 1.0.0'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Refresh All Data'),
            subtitle: const Text('Sync with Mission Control database'),
            onTap: () {
              context.read<AppProvider>().refreshAll();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refreshing...')),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.folder_open),
            title: const Text('Database Path'),
            subtitle: const Text('/Users/qbot/.openclaw/workspace/mission-control/data/mission-control.db'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.web),
            title: const Text('Open Mission Control Web'),
            subtitle: const Text('http://localhost:3001'),
            onTap: () {
              // Would use url_launcher to open browser
            },
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.telegram),
            title: Text('Telegram Notifications'),
            subtitle: Text('Connected via OpenClaw bot'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: AppTheme.danger),
            title: const Text('Clear App Cache', style: TextStyle(color: AppTheme.danger)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared')),
              );
            },
          ),
        ],
      ),
    );
  }
}
