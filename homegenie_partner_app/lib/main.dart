import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/theme/app_theme.dart';
import '../shared/config/app_config.dart';
import 'core/storage/storage_service.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage
  final storage = StorageService();
  await storage.init();

  runApp(
    ProviderScope(
      overrides: [
        // Provide storage service to the app
        storageServiceProvider.overrideWithValue(storage),
      ],
      child: HomeGeniePartnerApp(storage: storage),
    ),
  );
}

// Storage service provider for dependency injection
final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('Storage service must be overridden in main()');
});

class HomeGeniePartnerApp extends StatelessWidget {
  final StorageService storage;

  const HomeGeniePartnerApp({
    super.key,
    required this.storage,
  });

  @override
  Widget build(BuildContext context) {
    final router = AppRouter(storage);

    return MaterialApp.router(
      title: AppConfig.partnerAppName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(context),
      routerConfig: router.router,
    );
  }
}
