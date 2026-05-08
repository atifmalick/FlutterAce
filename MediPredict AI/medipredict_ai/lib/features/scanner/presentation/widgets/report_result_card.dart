import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/medical_report.dart';

class ReportResultCard extends StatelessWidget {
  final List<ExtractedBiomarker> biomarkers;
  const ReportResultCard({super.key, required this.biomarkers});

  @override
  Widget build(BuildContext context) {
    if (biomarkers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(children: [
          Icon(Icons.search_off_rounded, size: 48, color: AppColors.textLight.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text('No biomarkers detected', style: AppTextStyles.heading3),
          const SizedBox(height: 4),
          Text('Try scanning a clearer image of a blood test report', style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
        ]),
      );
    }
    final abnormal = biomarkers.where((b) => b.isAbnormal).length;
    final normal = biomarkers.where((b) => !b.isAbnormal).length;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(20), boxShadow: AppColors.cardShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.biotech_rounded, color: AppColors.primary, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Analysis Results', style: AppTextStyles.heading3),
            Text('${biomarkers.length} biomarkers found', style: AppTextStyles.bodySmall),
          ])),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          _chip('Normal', normal, AppColors.riskLow),
          const SizedBox(width: 8),
          _chip('Abnormal', abnormal, AppColors.riskHigh),
        ]),
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 12),
        ...biomarkers.map((b) => _biomarkerRow(b)),
      ]),
    );
  }

  Widget _chip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text('$count $label', style: AppTextStyles.chip.copyWith(color: color)),
      ]),
    );
  }

  Widget _biomarkerRow(ExtractedBiomarker b) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Container(width: 4, height: 40, decoration: BoxDecoration(color: b.isAbnormal ? AppColors.riskHigh : AppColors.riskLow, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(b.name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
          Text('Ref: ${b.refMin} - ${b.refMax} ${b.unit}', style: AppTextStyles.caption),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${b.value}', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, color: b.isAbnormal ? AppColors.riskHigh : AppColors.riskLow)),
          Text(b.unit, style: AppTextStyles.caption),
        ]),
        const SizedBox(width: 8),
        Icon(b.isAbnormal ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded, color: b.isAbnormal ? AppColors.riskHigh : AppColors.riskLow, size: 20),
      ]),
    );
  }
}
