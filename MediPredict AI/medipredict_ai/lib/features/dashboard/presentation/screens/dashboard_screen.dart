import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/health_trend_chart.dart';
import '../widgets/risk_score_card.dart';
import '../widgets/quick_stats_row.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final dashState = ref.watch(dashboardProvider);
    final firstName = authState.profile?.fullName.split(' ').first ?? 'User';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => ref.read(dashboardProvider.notifier).loadData(),
        child: CustomScrollView(
          slivers: [
            // Custom App Bar
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: AppConstants.paddingLarge,
                  right: AppConstants.paddingLarge,
                  bottom: 24,
                ),
                decoration: const BoxDecoration(
                  gradient: AppColors.darkGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, $firstName 👋',
                                style: AppTextStyles.heading2.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'How are you feeling today?',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/profile'),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Quick action buttons
                    Row(
                      children: [
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.document_scanner_rounded,
                            label: 'Scan Report',
                            onTap: () => context.go('/scanner'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.chat_bubble_rounded,
                            label: 'Symptom Check',
                            onTap: () => context.go('/chat'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Content
            SliverPadding(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 4),
                  // Risk Score Card
                  RiskScoreCard(
                    score: dashState.latestLog?.severityScore,
                  ),
                  const SizedBox(height: 16),
                  // Quick Stats
                  QuickStatsRow(
                    totalLogs: dashState.healthLogs.length,
                    totalScans: dashState.totalScans,
                    avgSeverity: dashState.averageSeverity,
                  ),
                  const SizedBox(height: 20),
                  // Health Trend Chart
                  HealthTrendChart(logs: dashState.healthLogs),
                  const SizedBox(height: 100), // Bottom nav clearance
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white54,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
