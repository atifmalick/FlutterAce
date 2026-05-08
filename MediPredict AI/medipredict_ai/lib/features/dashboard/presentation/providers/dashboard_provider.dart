import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/health_log.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl();
});

// Dashboard state
class DashboardState {
  final bool isLoading;
  final List<HealthLog> healthLogs;
  final int totalScans;
  final HealthLog? latestLog;
  final String? error;

  const DashboardState({
    this.isLoading = true,
    this.healthLogs = const [],
    this.totalScans = 0,
    this.latestLog,
    this.error,
  });

  DashboardState copyWith({
    bool? isLoading,
    List<HealthLog>? healthLogs,
    int? totalScans,
    HealthLog? latestLog,
    String? error,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      healthLogs: healthLogs ?? this.healthLogs,
      totalScans: totalScans ?? this.totalScans,
      latestLog: latestLog ?? this.latestLog,
      error: error,
    );
  }

  double get averageSeverity {
    if (healthLogs.isEmpty) return 0;
    final sum = healthLogs.fold<int>(
      0,
      (prev, log) => prev + log.severityScore,
    );
    return sum / healthLogs.length;
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final DashboardRepository _repository;
  final String? _userId;

  DashboardNotifier(this._repository, this._userId)
      : super(const DashboardState()) {
    if (_userId != null) loadData();
  }

  Future<void> loadData() async {
    if (_userId == null) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final logs = await _repository.getHealthLogs(_userId);
      final scans = await _repository.getTotalScans(_userId);
      final latest = await _repository.getLatestLog(_userId);
      state = DashboardState(
        isLoading: false,
        healthLogs: logs,
        totalScans: scans,
        latestLog: latest,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final repo = ref.watch(dashboardRepositoryProvider);
  final userId = ref.watch(authProvider).profile?.id;
  return DashboardNotifier(repo, userId);
});
