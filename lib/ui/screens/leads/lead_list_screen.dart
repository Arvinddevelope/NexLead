import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nextlead/core/constants/app_colors.dart';
import 'package:nextlead/core/constants/app_texts.dart';
import 'package:nextlead/data/models/lead_model.dart';
import 'package:nextlead/providers/lead_provider.dart';
import 'package:nextlead/providers/notification_provider.dart';
import 'package:nextlead/routes/app_routes.dart';
import 'package:nextlead/ui/components/bottom_nav_bar.dart';
import 'package:nextlead/ui/widgets/lead_card.dart';

class LeadListScreen extends StatefulWidget {
  const LeadListScreen({super.key});

  @override
  State<LeadListScreen> createState() => _LeadListScreenState();
}

class _LeadListScreenState extends State<LeadListScreen> {
  int _currentIndex = 1;
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = '';
  final List<String> _statusFilters = [
    '',
    'New',
    'Contacted',
    'Qualified',
    'Converted',
    'Lost'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final leadProvider = Provider.of<LeadProvider>(context, listen: false);
      leadProvider.loadLeads();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;

      // Handle navigation based on index
      switch (index) {
        case 0: // Dashboard
          Navigator.pushNamed(context, AppRoutes.dashboard);
          break;
        case 1: // Leads
          // Already on leads screen
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

  void _filterLeads() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppTexts.leadsTitle),
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
          IconButton(
            onPressed: () {
              // Show filter options
              _showFilterOptions();
            },
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppTexts.searchLeads,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          // Status Filter Chips
          if (_selectedStatus.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FilterChip(
                  label: Text(_selectedStatus),
                  onSelected: (selected) {
                    setState(() {
                      _selectedStatus = selected ? _selectedStatus : '';
                    });
                  },
                  onDeleted: () {
                    setState(() {
                      _selectedStatus = '';
                    });
                  },
                  deleteIcon: const Icon(Icons.close, size: 18),
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  selectedColor: AppColors.primary,
                ),
              ),
            ),
          const SizedBox(height: 16),
          // Leads List
          Expanded(
            child: Consumer<LeadProvider>(
              builder: (context, leadProvider, child) {
                if (leadProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (leadProvider.errorMessage.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(leadProvider.errorMessage),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: leadProvider.loadLeads,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                // Filter leads based on search and status
                List<Lead> filteredLeads = leadProvider.leads;

                // Apply search filter
                if (_searchController.text.isNotEmpty) {
                  filteredLeads =
                      leadProvider.searchLeads(_searchController.text);
                }

                // Apply status filter
                if (_selectedStatus.isNotEmpty) {
                  filteredLeads =
                      leadProvider.filterLeadsByStatus(_selectedStatus);
                }

                if (filteredLeads.isEmpty) {
                  return const Center(
                    child: Text(AppTexts.noLeadsFound),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredLeads.length,
                  itemBuilder: (context, index) {
                    final lead = filteredLeads[index];
                    return LeadCard(
                      lead: lead,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.leadDetail,
                          arguments: lead,
                        );
                      },
                      onCall: () {
                        // Handle call action
                      },
                      onEmail: () {
                        // Handle email action
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            AppRoutes.leadForm,
            arguments: null, // null indicates new lead
          );
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter by Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _statusFilters.map((status) {
                  return FilterChip(
                    label: Text(
                      status.isEmpty ? 'All' : status,
                    ),
                    selected: _selectedStatus == status,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = selected ? status : '';
                      });
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
