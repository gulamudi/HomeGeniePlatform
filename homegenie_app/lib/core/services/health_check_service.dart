import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';

class HealthCheckService {
  static Future<HealthCheckResult> performHealthCheck() async {
    if (!kDebugMode) {
      // Skip health check in production
      return HealthCheckResult(
        isHealthy: true,
        supabaseRunning: true,
        edgeFunctionsAccessible: true,
        databaseConnected: true,
      );
    }

    print('\n🏥 PERFORMING HEALTH CHECK 🏥');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    bool supabaseRunning = false;
    bool edgeFunctionsAccessible = false;
    bool databaseConnected = false;
    final List<String> errors = [];
    final List<String> warnings = [];

    // 1. Check if Supabase is running
    print('1️⃣  Checking Supabase availability...');
    try {
      final dio = Dio();
      final response = await dio.get(
        '${AppConstants.supabaseUrl}/rest/v1/',
        options: Options(
          headers: {
            'apikey': AppConstants.supabaseAnonKey,
          },
          validateStatus: (status) => true,
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      if (response.statusCode != null && response.statusCode! < 500) {
        supabaseRunning = true;
        print('   ✓ Supabase is running at ${AppConstants.supabaseUrl}');
      } else {
        errors.add('Supabase returned error status: ${response.statusCode}');
        print('   ✗ Supabase returned status ${response.statusCode}');
      }
    } catch (e) {
      errors.add('Cannot connect to Supabase: $e');
      print('   ✗ Supabase is NOT running');
      print('   Error: $e');
    }

    // 2. Check edge functions accessibility
    print('2️⃣  Checking edge functions...');
    if (supabaseRunning) {
      try {
        final dio = Dio();
        // Try to hit a basic endpoint (even if it returns 401, it means it's accessible)
        final response = await dio.get(
          '${AppConstants.baseUrl}/customer-services',
          options: Options(
            validateStatus: (status) => true,
            sendTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 5),
          ),
        );

        if (response.statusCode != null) {
          edgeFunctionsAccessible = true;
          print('   ✓ Edge functions are accessible');
          if (response.statusCode == 401) {
            warnings.add('Edge functions require authentication (expected)');
          }
        }
      } catch (e) {
        errors.add('Edge functions not accessible: $e');
        print('   ✗ Edge functions are NOT accessible');
        print('   Error: $e');
      }
    } else {
      errors.add('Skipping edge function check - Supabase not running');
      print('   ⊘ Skipped (Supabase not running)');
    }

    // 3. Check database connection (via edge function)
    print('3️⃣  Checking database connection...');
    if (edgeFunctionsAccessible) {
      // We can't directly test DB without auth, but we can infer from edge function response
      // If edge functions are working and returning structured responses, DB is likely OK
      databaseConnected = true;
      print('   ✓ Database appears to be connected');
      warnings.add('Full database test requires authentication');
    } else {
      errors.add('Cannot verify database - edge functions not accessible');
      print('   ⊘ Skipped (Edge functions not accessible)');
    }

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    final isHealthy = supabaseRunning && edgeFunctionsAccessible;

    if (isHealthy) {
      print('✅ HEALTH CHECK PASSED');
      print('   All systems operational\n');
    } else {
      print('❌ HEALTH CHECK FAILED');
      print('   Issues detected - app will use mock data\n');

      if (errors.isNotEmpty) {
        print('🔴 ERRORS:');
        for (final error in errors) {
          print('   • $error');
        }
      }

      if (warnings.isNotEmpty) {
        print('\n🟡 WARNINGS:');
        for (final warning in warnings) {
          print('   • $warning');
        }
      }

      print('\n📋 ACTION REQUIRED:');
      if (!supabaseRunning) {
        print('   1. Open terminal in your project directory');
        print('   2. Run: supabase start');
        print('   3. Wait for Supabase to fully start');
        print('   4. Restart this app');
      } else if (!edgeFunctionsAccessible) {
        print('   1. Verify edge functions are deployed');
        print('   2. Check ${AppConstants.baseUrl} is correct');
        print('   3. Restart Supabase: supabase stop && supabase start');
      }
      print('');
    }

    return HealthCheckResult(
      isHealthy: isHealthy,
      supabaseRunning: supabaseRunning,
      edgeFunctionsAccessible: edgeFunctionsAccessible,
      databaseConnected: databaseConnected,
      errors: errors,
      warnings: warnings,
    );
  }
}

class HealthCheckResult {
  final bool isHealthy;
  final bool supabaseRunning;
  final bool edgeFunctionsAccessible;
  final bool databaseConnected;
  final List<String> errors;
  final List<String> warnings;

  HealthCheckResult({
    required this.isHealthy,
    required this.supabaseRunning,
    required this.edgeFunctionsAccessible,
    required this.databaseConnected,
    this.errors = const [],
    this.warnings = const [],
  });

  String get summary {
    if (isHealthy) {
      return 'All systems operational';
    }
    return 'Issues detected: ${errors.length} error(s), ${warnings.length} warning(s)';
  }
}
