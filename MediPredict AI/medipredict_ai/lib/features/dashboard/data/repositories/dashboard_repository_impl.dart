import '../../domain/entities/health_log.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../../../core/supabase_client.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  @override
  Future<List<HealthLog>> getHealthLogs(String userId) async {
    final response = await SupabaseClientHelper.healthLogs()
        .select()
        .eq('user_id', userId)
        .order('timestamp', ascending: true)
        .limit(30);

    return (response as List)
        .map((json) => HealthLog.fromJson(json))
        .toList();
  }

  @override
  Future<int> getTotalScans(String userId) async {
    final response = await SupabaseClientHelper.medicalReports()
        .select('id')
        .eq('user_id', userId);
    return (response as List).length;
  }

  @override
  Future<HealthLog?> getLatestLog(String userId) async {
    final response = await SupabaseClientHelper.healthLogs()
        .select()
        .eq('user_id', userId)
        .order('timestamp', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return HealthLog.fromJson(response);
  }
}
