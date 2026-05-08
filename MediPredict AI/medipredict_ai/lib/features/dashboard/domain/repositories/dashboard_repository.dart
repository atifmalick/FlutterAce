import '../entities/health_log.dart';

abstract class DashboardRepository {
  Future<List<HealthLog>> getHealthLogs(String userId);
  Future<int> getTotalScans(String userId);
  Future<HealthLog?> getLatestLog(String userId);
}
