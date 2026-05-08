import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientHelper {
  SupabaseClientHelper._();

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }

  static GoTrueClient get auth => client.auth;
  static SupabaseQueryBuilder profiles() => client.from('profiles');
  static SupabaseQueryBuilder healthLogs() => client.from('health_logs');
  static SupabaseQueryBuilder medicalReports() => client.from('medical_reports');
  static SupabaseStorageClient get storage => client.storage;
}
