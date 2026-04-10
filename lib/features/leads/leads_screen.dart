import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/providers/app_provider.dart';
import '../../shared/models/lead_model.dart';
import '../../core/theme/app_theme.dart';

class LeadsScreen extends StatefulWidget {
  const LeadsScreen({super.key});

  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AppProvider>().loadLeads());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        if (provider.leads.isEmpty && provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.leads.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.people_outline, size: 64, color: AppTheme.grey),
                const SizedBox(height: 16),
                const Text('No leads yet'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.loadLeads(),
                  child: const Text('Refresh'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadLeads(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.leads.length,
            itemBuilder: (context, index) => _LeadCard(lead: provider.leads[index]),
          ),
        );
      },
    );
  }
}

class _LeadCard extends StatelessWidget {
  final LeadModel lead;

  const _LeadCard({required this.lead});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showLeadDialog(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(lead.statusLabel, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lead.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        if (lead.company != null)
                          Text(lead.company!, style: const TextStyle(fontSize: 13, color: AppTheme.grey)),
                      ],
                    ),
                  ),
                  _ScoreBadge(score: lead.score),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (lead.sector != null) Chip(label: Text(lead.sector!, )),
                  if (lead.location != null) Chip(label: Text(lead.location!, )),
                  if (lead.size != null) Chip(label: Text(lead.size!, )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLeadDialog(BuildContext context) {
    final provider = context.read<AppProvider>();
    final statuses = ['new', 'contacted', 'qualified', 'proposal', 'won', 'lost'];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lead.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            if (lead.company != null) Text(lead.company!, style: const TextStyle(color: AppTheme.grey)),
            const SizedBox(height: 24),
            const Text('Change Status', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: statuses.map((s) {
                final isSelected = s == lead.status;
                return ChoiceChip(
                  label: Text(_statusLabel(s)),
                  selected: isSelected,
                  onSelected: (_) async {
                    Navigator.pop(ctx);
                    await provider.updateLeadStatus(lead.id!, s);
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

  String _statusLabel(String s) {
    switch (s) {
      case 'new': return '🆕 New';
      case 'contacted': return '📧 Contacted';
      case 'qualified': return '✅ Qualified';
      case 'proposal': return '📄 Proposal';
      case 'won': return '🎉 Won';
      case 'lost': return '❌ Lost';
      default: return s;
    }
  }
}

class _ScoreBadge extends StatelessWidget {
  final double score;

  const _ScoreBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    Color color;
    if (score >= 80) {
      color = AppTheme.success;
    } else if (score >= 50) {
      color = AppTheme.warning;
    } else {
      color = AppTheme.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
      child: Text(score.toStringAsFixed(0), style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }
}
