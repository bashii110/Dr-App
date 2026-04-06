import 'package:doctor_app/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/config.dart';
import 'utils/main_layout.dart';
import 'auth/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doctor App',
      debugShowCheckedModeBanner: false,
      theme: Config.theme,
      home: const _AuthRouter(),
    );
  }
}

// Listens to AuthProvider and routes to the right screen.
class _AuthRouter extends StatefulWidget {
  const _AuthRouter();
  @override
  State<_AuthRouter> createState() => _AuthRouterState();
}

class _AuthRouterState extends State<_AuthRouter> {
  @override
  void initState() {
    super.initState();
    // Check for a saved token on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    switch (auth.status) {
      case AuthStatus.unknown:
      // Splash / loading
        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.medical_services_rounded,
                    size: 64, color: Config.primaryColor),
                SizedBox(height: 24),
                CircularProgressIndicator(color: Config.primaryColor),
              ],
            ),
          ),
        );

      case AuthStatus.authenticated:
        return const MainLayout();

      case AuthStatus.unauthenticated:
        return const LoginScreen();
    }
  }
}