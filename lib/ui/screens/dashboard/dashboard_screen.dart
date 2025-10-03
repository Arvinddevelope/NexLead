import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nextlead/core/constants/app_colors.dart';
import 'package:nextlead/core/constants/app_texts.dart';
import 'package:nextlead/core/utils/helpers.dart';
import 'package:nextlead/data/models/lead_model.dart';
import 'package:nextlead/providers/lead_provider.dart';
import 'package:nextlead/providers/notification_provider.dart';
import 'package:nextlead/providers/task_provider.dart';
import 'package:nextlead/routes/app_routes.dart';
import 'package:nextlead/ui/components/bottom_nav_bar.dart';
import 'package:nextlead/ui/widgets/task_tile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final leadProvider = Provider.of<LeadProvider>(context, listen: false);
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);

      leadProvider.loadLeads();
      taskProvider.loadTasks();
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;

      // Handle navigation based on index
      switch (index) {
        case 0: // Dashboard
          // Already on dashboard
          break;
        case 1: // Leads
          Navigator.pushNamed(context, AppRoutes.leads);
          break;
        case 2: // Tasks
          Navigator.pushNamed(context, AppRoutes.tasks);
          break;
        case 3: // Notes
          Navigator.pushNamed(context, AppRoutes.notes);
          break;
        case 4: // Settings
          Navigator.pushNamed(context, AppRoutes.settings);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppTexts.dashboardTitle),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              final unreadCount = notificationProvider.unreadCount;
              return Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      // Navigate to notifications screen
                      Navigator.pushNamed(context, AppRoutes.notifications);
                    },
                    icon: const Icon(Icons.notifications_none),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: AppColors.statusLost,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount > 9 ? '9+' : unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Summary Cards
            SummaryCards(),
            SizedBox(height: 20),

            // Lead Status Chart
            LeadStatusChart(),
            SizedBox(height: 20),

            // Today's Follow-ups
            TodaysFollowUps(),
            SizedBox(height: 20),

            // Today's Tasks
            TodaysTasks(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

class SummaryCards extends StatelessWidget {
  const SummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LeadProvider>(
      builder: (context, leadProvider, child) {
        return Column(
          children: [
            // First row - Total Leads and Converted/Won Leads
            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: AppTexts.totalLeads,
                    value: leadProvider.totalLeads.toString(),
                    icon: Icons.group,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SummaryCard(
                    title: 'Converted/Won Leads',
                    value: leadProvider.convertedLeads.toString(),
                    icon: Icons.stars,
                    color: AppColors.statusConverted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Second row - Proposal Leads and Contacted Leads
            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: 'Proposal Leads',
                    value: leadProvider.proposalLeads.toString(),
                    icon: Icons.description,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SummaryCard(
                    title: 'Contacted Leads',
                    value: leadProvider.contactedLeads.toString(),
                    icon: Icons.phone_in_talk,
                    color: AppColors.statusContacted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Third row - Qualified Leads and New Leads
            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: 'Qualified Leads',
                    value: leadProvider.qualifiedLeads.toString(),
                    icon: Icons.check_circle,
                    color: AppColors.statusQualified,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SummaryCard(
                    title: 'New Leads',
                    value: leadProvider.newLeads.toString(),
                    icon: Icons.new_releases,
                    color: AppColors.statusNew,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Fourth row - Pending Leads and Lost Leads
            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: 'Pending Leads',
                    value: leadProvider.pendingLeads.toString(),
                    icon: Icons.hourglass_empty,
                    color: AppColors.statusContacted,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SummaryCard(
                    title: 'Lost Leads',
                    value: leadProvider.lostLeads.toString(),
                    icon: Icons.cancel,
                    color: AppColors.statusLost,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class LeadStatusChart extends StatelessWidget {
  const LeadStatusChart({super.key});

  List<PieChartSectionData> _showingSections(LeadProvider leadProvider) {
    // Updated to match the actual status values used in the app
    final newLeads = leadProvider.filterLeadsByStatus('New').length;
    final contactedLeads = leadProvider.filterLeadsByStatus('Contacted').length;
    final qualifiedLeads = leadProvider.filterLeadsByStatus('Qualified').length;
    final proposalLeads = leadProvider.filterLeadsByStatus('Proposal').length;
    final wonLeads = leadProvider.filterLeadsByStatus('Won').length;
    final lostLeads = leadProvider.filterLeadsByStatus('Lost').length;

    final total = newLeads +
        contactedLeads +
        qualifiedLeads +
        proposalLeads +
        wonLeads +
        lostLeads;

    if (total == 0) {
      return [
        PieChartSectionData(
          color: AppColors.gray300,
          value: 1,
          title: 'No Data',
          radius: 50,
        ),
      ];
    }

    return [
      if (newLeads > 0)
        PieChartSectionData(
          color: AppColors.statusNew,
          value: newLeads.toDouble(),
          title: '${(newLeads / total * 100).round()}%',
          radius: 50,
        ),
      if (contactedLeads > 0)
        PieChartSectionData(
          color: AppColors.statusContacted,
          value: contactedLeads.toDouble(),
          title: '${(contactedLeads / total * 100).round()}%',
          radius: 50,
        ),
      if (qualifiedLeads > 0)
        PieChartSectionData(
          color: AppColors.statusQualified,
          value: qualifiedLeads.toDouble(),
          title: '${(qualifiedLeads / total * 100).round()}%',
          radius: 50,
        ),
      if (proposalLeads > 0)
        PieChartSectionData(
          color: Colors.purple,
          value: proposalLeads.toDouble(),
          title: '${(proposalLeads / total * 100).round()}%',
          radius: 50,
        ),
      if (wonLeads > 0)
        PieChartSectionData(
          color: AppColors.statusConverted,
          value: wonLeads.toDouble(),
          title: '${(wonLeads / total * 100).round()}%',
          radius: 50,
        ),
      if (lostLeads > 0)
        PieChartSectionData(
          color: AppColors.statusLost,
          value: lostLeads.toDouble(),
          title: '${(lostLeads / total * 100).round()}%',
          radius: 50,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.gray300.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lead Status Distribution',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Consumer<LeadProvider>(
              builder: (context, leadProvider, child) {
                return PieChart(
                  PieChartData(
                    sections: _showingSections(leadProvider),
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TodaysFollowUps extends StatelessWidget {
  const TodaysFollowUps({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.gray300.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today\'s Follow-ups',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Consumer<LeadProvider>(
            builder: (context, leadProvider, child) {
              if (leadProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final todayFollowUps = leadProvider.todayFollowUps;

              if (todayFollowUps.isEmpty) {
                return const Center(
                  child: Text('No follow-ups scheduled for today'),
                );
              }

              return Column(
                children: todayFollowUps
                    .take(5)
                    .map((lead) => _FollowUpTile(lead: lead))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FollowUpTile extends StatelessWidget {
  final Lead lead;

  const _FollowUpTile({required this.lead});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gray300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lead.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                if (lead.company.isNotEmpty)
                  Text(
                    lead.company,
                    style: const TextStyle(
                      color: AppColors.gray600,
                      fontSize: 14,
                    ),
                  ),
                const SizedBox(height: 4),
                if (lead.contactName != null && lead.contactName!.isNotEmpty)
                  Text(
                    'Contact: ${lead.contactName}',
                    style: const TextStyle(
                      color: AppColors.gray600,
                      fontSize: 12,
                    ),
                  ),
                const SizedBox(height: 4),
                if (lead.nextFollowUp != null)
                  Text(
                    'Follow-up: ${Helpers.formatDateTime(lead.nextFollowUp!)}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(lead.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    lead.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.gray500,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'New':
        return AppColors.statusNew;
      case 'Contacted':
        return AppColors.statusContacted;
      case 'Qualified':
        return AppColors.statusQualified;
      case 'Proposal':
        return Colors.purple;
      case 'Won':
        return AppColors.statusConverted;
      case 'Lost':
        return AppColors.statusLost;
      default:
        return AppColors.gray500;
    }
  }
}

class TodaysTasks extends StatelessWidget {
  const TodaysTasks({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.gray300.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                AppTexts.todaysTasks,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.tasks);
                },
                child: const Text(AppTexts.viewAll),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Consumer<TaskProvider>(
            builder: (context, taskProvider, child) {
              if (taskProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final todayTasks = taskProvider.todayTasks;

              if (todayTasks.isEmpty) {
                return const Center(
                  child: Text('No tasks for today'),
                );
              }

              return Column(
                children: todayTasks
                    .take(5) // Increase from 3 to 5 tasks
                    .map((task) => TaskTile(
                          task: task,
                          onTap: () {
                            // Handle task tap
                          },
                          onCheckboxChanged: (value) {
                            // Handle task completion toggle
                          },
                          onDelete: () {
                            // Handle task deletion
                          },
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
