import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared/config/app_config.dart';
import 'package:shared/theme/app_theme.dart';
import 'core/storage/storage_service.dart';
import 'core/router/app_router.dart';
import 'core/services/health_check_service.dart';
import 'core/constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage
  await StorageService.init();

  // Initialize Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  // Perform health check in debug mode
  if (kDebugMode) {
    await HealthCheckService.performHealthCheck();
  }

  runApp(
    const ProviderScope(
      child: HomeGenieApp(),
    ),
  );
}

class HomeGenieApp extends ConsumerWidget {
  const HomeGenieApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: AppConfig.appName,
      theme: AppTheme.lightTheme(context),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
