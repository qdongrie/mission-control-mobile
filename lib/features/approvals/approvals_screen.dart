import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../shared/providers/app_provider.dart';
import '../shared/models/approval_model.dart';
import '../core/theme/app_theme.dart';

class ApprovalsScreen extends StatefulWidget {
  const ApprovalsScreen({super.key});

  @override
  State<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends State<ApprovalsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AppProvider>().loadApprovals());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        if (provider.approvals.isEmpty && provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final pending = provider.pendingApprovalsList;

        return RefreshIndicator(
          onRefresh: () => provider.loadApprovals(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header
              if (pending.isNotEmpty)
                Card(
                  color: AppTheme.warning.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.pending_actions, color: AppTheme.warning),
                        const SizedBox(width: 12),
                        Text('${pending.length} pending approval${pending.length > 1 ? 's' : ''}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Pending
              if (pending.isNotEmpty) ...[
                const Text('Pending', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...pending.map((a) => _ApprovalCard(
                      approval: a,
                      onApprove: () => _approve(a),
                      onReject: () => _showRejectDialog(a),
                    )),
                const SizedBox(height: 24),
              ],

              // Processed
              if (provider.approvals.any((a) => !a.isPending)) ...[
                const Text('Processed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...provider.approvals
                    .where((a) => !a.isPending)
                    .map((a) => _ApprovalCard(approval: a, isReadOnly: true)),
              ],

              if (pending.isEmpty && !provider.approvals.any((a) => !a.isPending))
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.check_circle_outline, size: 64, color: AppTheme.success),
                        SizedBox(height: 16),
                        Text('All caught up!', style: TextStyle(fontSize: 18)),
                        Text('No pending approvals', style: TextStyle(color: AppTheme.grey)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _approve(ApprovalModel approval) async {
    final provider = context.read<AppProvider>();
    await provider.approveItem(approval.id!);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${approval.agent} approved ✅'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  void _showRejectDialog(ApprovalModel approval) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Reason (optional)',
            hintText: 'Why are you rejecting this?',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = context.read<AppProvider>();
              await provider.rejectItem(approval.id!, reason: reasonController.text);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${approval.agent} rejected ❌'),
                    backgroundColor: AppTheme.danger,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}

class _ApprovalCard extends StatelessWidget {
  final ApprovalModel approval;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final bool isReadOnly;

  const _ApprovalCard({required this.approval, this.onApprove, this.onReject, this.isReadOnly = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(approval.typeIcon, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(approval.agent, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(approval.type.toUpperCase(), style: const TextStyle(fontSize: 12, color: AppTheme.grey)),
                    ],
                  ),
                ),
                _StatusChip(status: approval.status),
              ],
            ),
            if (approval.preview != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.light,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  approval.preview!,
                  style: const TextStyle(fontSize: 13),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            if (approval.reason != null) ...[
              const SizedBox(height: 8),
              Text('Reason: ${approval.reason}', style: const TextStyle(fontSize: 12, color: AppTheme.grey)),
            ],
            if (!isReadOnly && approval.isPending) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(foregroundColor: AppTheme.danger),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case 'approved':
        color = AppTheme.success;
        label = 'Approved';
        break;
      case 'rejected':
        color = AppTheme.danger;
        label = 'Rejected';
        break;
      default:
        color = AppTheme.warning;
        label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
