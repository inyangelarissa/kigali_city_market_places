import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:city_market/services/auth_service.dart';
import 'package:city_market/services/data_seeder.dart';
import 'package:city_market/views/main_navigation.dart';
import 'package:city_market/views/login_screen.dart';
import 'package:city_market/views/verify_email_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);
    ref.listen(authStateChangesProvider, (previous, next) {
      ref.read(authServiceProvider).resetSessionTimer();
      next.whenData((user) {
        if (user != null && user.emailVerified) {
          DataSeeder().seedIfEmpty();
        }
      });
    });

    return authState.when(
      data: (user) {
        if (user != null) {
          if (user.emailVerified) {
            return const MainNavigation();
          } else {
            return const VerifyEmailScreen();
          }
        } else {
          return LoginScreen();
        }
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }
}
