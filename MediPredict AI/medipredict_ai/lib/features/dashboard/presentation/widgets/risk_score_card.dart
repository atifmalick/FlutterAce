import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';

class RiskScoreCard extends StatelessWidget {
  final int? score;

  const RiskScoreCard({super.key, this.score});

  @override
  Widget build(BuildContext context) {
    final riskLabel = score != null ? AppConstants.riskLabel(score!) : 'N/A';
    final riskColor = _riskColor(riskLabel);
    final riskBgColor = _riskBgColor(riskLabel);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: score != null
            ? LinearGradient(
                colors: [riskColor.withValues(alpha: 0.1), riskBgColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
        border: Border.all(
          color: riskColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.monitor_heart_rounded,
                  color: riskColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text('Latest Risk', style: AppTextStyles.label),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                score?.toString() ?? '-',
                style: AppTextStyles.statValue.copyWith(
                  fontSize: 36,
                  color: riskColor,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('/10', style: AppTextStyles.bodySmall),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  riskLabel,
                  style: AppTextStyles.chip.copyWith(color: riskColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _riskColor(String label) {
    switch (label) {
      case 'Low':
        return AppColors.riskLow;
      case 'Medium':
        return AppColors.riskMedium;
      case 'High':
        return AppColors.riskHigh;
      default:
        return AppColors.textLight;
    }
  }

  Color _riskBgColor(String label) {
    switch (label) {
      case 'Low':
        return AppColors.successLight;
      case 'Medium':
        return AppColors.warningLight;
      case 'High':
        return AppColors.errorLight;
      default:
        return AppColors.surfaceVariant;
    }
  }
}
