import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/theme/app_theme.dart';
import '../shared/config/app_config.dart';
import 'core/storage/storage_service.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage
  await StorageService.init();

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
