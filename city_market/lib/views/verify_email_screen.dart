import 'package:city_market/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _checking = false;

  Future<void> _checkVerification() async {
    setState(() => _checking = true);
    try {
      final verified = await ref.read(authServiceProvider).reloadAndCheckEmailVerified();
      if (!mounted) return;
      if (!verified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email is not verified yet. Please check your inbox.')),
        );
      }
      // If verified, AuthWrapper will route automatically after reload.
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification check failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF7ED), Color(0xFFFEEBC8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.mark_email_unread_outlined, size: 64),
                    const SizedBox(height: 16),
                    const Text(
                      'Verify your email',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'A verification link has been sent. Open your inbox, then tap the button below.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _checking ? null : _checkVerification,
                        child: _checking
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('I have verified my email'),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        try {
                          await ref.read(authServiceProvider).sendEmailVerification();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Verification email sent')),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to resend email: $e')),
                          );
                        }
                      },
                      child: const Text('Resend verification email'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await ref.read(authServiceProvider).signOut();
                      },
                      child: const Text('Back to Login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
