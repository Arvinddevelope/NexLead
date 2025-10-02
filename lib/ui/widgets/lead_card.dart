import 'package:flutter/material.dart';
import 'package:nextlead/core/constants/app_colors.dart';
import 'package:nextlead/core/constants/app_texts.dart';
import 'package:nextlead/core/utils/helpers.dart';
import 'package:nextlead/data/models/lead_model.dart';

class LeadCard extends StatelessWidget {
  final Lead lead;
  final VoidCallback onTap;
  final VoidCallback onCall;
  final VoidCallback onEmail;

  const LeadCard({
    super.key,
    required this.lead,
    required this.onTap,
    required this.onCall,
    required this.onEmail,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'New':
        return AppColors.statusNew;
      case 'Contacted':
        return AppColors.statusContacted;
      case 'Qualified':
        return AppColors.statusQualified;
      case 'Converted':
        return AppColors.statusConverted;
      case 'Lost':
        return AppColors.statusLost;
      default:
        return AppColors.gray500;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'New':
        return Icons.new_releases;
      case 'Contacted':
        return Icons.phone_in_talk;
      case 'Qualified':
        return Icons.check_circle;
      case 'Converted':
        return Icons.stars;
      case 'Lost':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      lead.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(lead.status),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(lead.status),
                          size: 16,
                          color: AppColors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          lead.status,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (lead.company.isNotEmpty)
                Text(
                  lead.company,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.gray600,
                  ),
                ),
              if (lead.company.isNotEmpty) const SizedBox(height: 4),
              Text(
                lead.email,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.gray600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                lead.phone,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.gray600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${AppTexts.sourceHint}: ${lead.source}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.gray500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    Helpers.formatDate(lead.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.gray500,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: onCall,
                    icon: const Icon(
                      Icons.call,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onEmail,
                    icon: const Icon(
                      Icons.email,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
