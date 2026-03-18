import 'core/config/env_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (!EnvConfig.isConfigured) {
    debugPrint('WARNING: Environment variables not configured.');
  }

  // Initialize Supabase
  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
  );

  runApp(
    const ProviderScope(
      child: CosmicTalksApp(),
    ),
  );
}

class CosmicTalksApp extends ConsumerWidget {
  const CosmicTalksApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'CosmicTalksAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterialDesign: true,
      ),
      routerConfig: router,
    );
  }
}
