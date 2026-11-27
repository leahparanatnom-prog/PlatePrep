import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'constants/app_theme.dart';
import 'constants/app_colors.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;
  } catch (e) {
    debugPrint('Firebase initialization note: $e');
    // Continues gracefully so app UI and offline/preview flows remain testable
  }

  runApp(PlatePrepApp(isFirebaseReady: firebaseInitialized));
}

class PlatePrepApp extends StatelessWidget {
  final bool isFirebaseReady;

  const PlatePrepApp({super.key, required this.isFirebaseReady});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final firestoreService = FirestoreService();

    return MaterialApp(
      title: 'PlatePrep',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: AuthStateWrapper(
        authService: authService,
        firestoreService: firestoreService,
      ),
    );
  }
}

/// Listens to Firebase Auth state changes and routes to Auth or Main App
class AuthStateWrapper extends StatelessWidget {
  final AuthService authService;
  final FirestoreService firestoreService;

  const AuthStateWrapper({
    super.key,
    required this.authService,
    required this.firestoreService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // While Firebase is establishing connection
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.restaurant_rounded,
                    size: 56,
                    color: AppColors.primary,
                  ),
                  SizedBox(height: 16),
                  CircularProgressIndicator(color: AppColors.primary),
                ],
              ),
            ),
          );
        }

        // Authenticated user exists
        final user = snapshot.data;
        if (user != null) {
          return MainNavigationScreen(
            userId: user.uid,
            authService: authService,
            firestoreService: firestoreService,
          );
        }

        // Unauthenticated -> Show Auth Screen
        return AuthScreen(authService: authService);
      },
    );
  }
}

