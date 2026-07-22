import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:balanza/l10n/app_localizations.dart';
import 'features/auth/presentation/login_view.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/transactions/presentation/home_view.dart';
import 'features/transactions/providers/transaction_provider.dart';
import 'features/settings/providers/locale_provider.dart';
import 'features/auth/presentation/biometric_lock_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  await Supabase.initialize(
    url: 'https://rlgnmcqergdjuxknhqhw.supabase.co',
    publishableKey: 'sb_publishable_qI0TdNv5VJQpKvlkSCassA_1slJiy9K',
  );

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStateAsync = ref.watch(authProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Balanza',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardColor: const Color(0xFF1E293B),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF7A5A),
          surface: Color(0xFF1E293B),
          onSurface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
      ),
      home: authStateAsync.when(
        data: (authState) {
          if (authState.session != null) {
            return const BiometricLockWrapper(child: HomeView());
          } else {
            return const LoginView();
          }
        },
        loading: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        error: (err, stack) => Scaffold(
          body: Center(
            child: Text('Authentication error: $err'),
          ),
        ),
      ),
    );
  }
}
