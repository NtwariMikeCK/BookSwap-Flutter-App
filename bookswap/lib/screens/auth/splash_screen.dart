import 'package:bookswap/core/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../providers/providers.dart';
import '../main/main_screen.dart';
import 'login_screen.dart';

/// Splash screen shown on app launch.
/// Checks authentication state and navigates accordingly.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Check auth state once on start
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // User already logged in → go to MainScreen
      Future.microtask(() {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        }
      });
    }
    // If user is null, do nothing → splash with Sign In button will be shown
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Book icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.accentYellow,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                size: 64,
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              'BookSwap',
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: AppTheme.textWhite,
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Swap Your Books\nWith Other Students',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 27,
                color: AppTheme.text_sub_heading1,
                wordSpacing: 1.5,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 32),

            const Text(
              'Sign In to get Started',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textGray,
                height: 1.5,
              ),
            ),
            // const CircularProgressIndicator(
            //   valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentYellow),
            // ),
            const SizedBox(height: 42),

            // Show Sign In button only if user is not logged in
            if (FirebaseAuth.instance.currentUser == null)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentYellow,
                  foregroundColor: AppTheme.primaryNavy,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 130,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Sign In', style: TextStyle(fontSize: 18)),
              ),
          ],
        ),
      ),
    );
  }
}
