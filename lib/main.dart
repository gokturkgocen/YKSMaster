import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/pages/main_screen.dart';
import 'presentation/pages/branch_selection_page.dart';
import 'presentation/providers/user_profile_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'presentation/providers/auth_provider.dart';
import 'features/auth/login_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('App starting...');
  // Initialize Firebase
  try {
    // We use the native google-services.json for Android/iOS configuration
    // This avoids mismatches if options.dart is not updated via CLI
    await Firebase.initializeApp();
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  // Initialize date formatting for Turkish locale
  await initializeDateFormatting('tr_TR', null);

  // Lock orientation to landscape only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final userProfile = ref.watch(userProfileProvider);

    return MaterialApp(
      title: 'YKS Master Tablet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: authState.when(
        data: (user) {
          if (user == null) {
            return const LoginScreen();
          }
          // Logged in
          if (userProfile.selectedBranch == null) {
            return const BranchSelectionPage();
          }
          return const MainScreen();
        },
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, stack) =>
            Scaffold(body: Center(child: Text('Bir hata oluştu: $e'))),
      ),
    );
  }
}
