import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/chat_message.dart';

class RiskScoreIndicator extends StatelessWidget {
  final TriageResult result;
  const RiskScoreIndicator({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final color = _riskColor(result.riskLevel);
    return Container(
      margin: const EdgeInsets.only(left: 0, right: 60, bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.08), color.withValues(alpha: 0.02)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(children: [
        // Score circle
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
          ),
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('${result.riskScore}', style: AppTextStyles.statValue.copyWith(fontSize: 20, color: color)),
              Text('/10', style: AppTextStyles.caption.copyWith(fontSize: 9, color: color)),
            ]),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
            child: Text(result.riskLevel, style: AppTextStyles.chip.copyWith(color: color, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 6),
          Text('Risk Assessment', style: AppTextStyles.caption),
        ])),
        Icon(_riskIcon(result.riskLevel), color: color, size: 28),
      ]),
    );
  }

  Color _riskColor(String level) {
    switch (level) {
      case 'Low': return AppColors.riskLow;
      case 'Medium': return AppColors.riskMedium;
      case 'High': return AppColors.riskHigh;
      default: return AppColors.textLight;
    }
  }

  IconData _riskIcon(String level) {
    switch (level) {
      case 'Low': return Icons.check_circle_rounded;
      case 'Medium': return Icons.warning_rounded;
      case 'High': return Icons.emergency_rounded;
      default: return Icons.help_rounded;
    }
  }
}
