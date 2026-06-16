import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vault/Providers/library_provider.dart';
import 'package:vault/Providers/user_provider.dart';
import 'package:vault/ui/Views/home_view.dart';
import 'package:vault/ui/Desktop/Library/library_page.dart';
import 'package:vault/ui/auth/login_page.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vault/ui/layout_scaffold.dart';

class Redirect extends StatefulWidget {
  const Redirect({Key? key}) : super(key: key);

  @override
  State<Redirect> createState() => _RedirectState();
}

class _RedirectState extends State<Redirect> {
  String? _initializedUid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // While the auth state is being determined (connectionState not active yet)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        }

        // If no user is logged in
        if (!snapshot.hasData) {
          return const LoginPage();
        }

        final uid = snapshot.data!.uid;
        if (_initializedUid != uid) {
          _initializedUid = uid;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Provider.of<LibraryProvider>(context, listen: false).init();
            Provider.of<UserProvider>(context, listen: false).init();
          });
        }

        // If user is found and connection is active
        return const LayoutScaffold();
      },
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/Vault.json',
              width: 160,
              height: 160,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            Text(
              'VAULT',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 8,
                color: const Color(0xFFCC0000),
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: Colors.white10,
                color: Color(0xFFCC0000),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
