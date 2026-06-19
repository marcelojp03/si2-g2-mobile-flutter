import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/theme/app_theme.dart';
import 'config/theme/theme_provider.dart';
import 'config/router/app_router.dart';
import 'core/http/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  ApiClient().init();
  runApp(const ProviderScope(child: SiaApp()));
}

class SiaApp extends ConsumerWidget {
  const SiaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'SIA - UAGRM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
    );
  }
}
