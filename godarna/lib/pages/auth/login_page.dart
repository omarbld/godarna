import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final emailController = TextEditingController();
  final codeController = TextEditingController();
  bool codeSent = false;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: Text(tr('auth.sign_in'))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Text(tr('auth.enter_email')),
            const SizedBox(height: 8),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(hintText: 'you@email.com'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: auth.isLoading
                  ? null
                  : () async {
                      await ref.read(authProvider.notifier).sendOtpToEmail(emailController.text.trim());
                      setState(() => codeSent = true);
                    },
              child: Text(tr('auth.send_code')),
            ),
            if (codeSent) ...[
              const SizedBox(height: 24),
              Text(tr('auth.enter_code')),
              const SizedBox(height: 8),
              TextField(
                controller: codeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: tr('auth.code_placeholder')),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: auth.isLoading
                    ? null
                    : () async {
                        final ok = await ref.read(authProvider.notifier).verifyEmailOtp(codeController.text.trim());
                        if (ok && mounted) context.go('/');
                      },
                child: Text(tr('auth.verify')),
              ),
            ],
            if (auth.errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(auth.errorMessage!, style: const TextStyle(color: Colors.red)),
            ],
            const Spacer(),
            TextButton(
              onPressed: () {
                final next = context.locale.languageCode == 'ar' ? const Locale('fr', 'FR') : const Locale('ar', 'MA');
                context.setLocale(next);
              },
              child: Text(tr('common.switch_language')),
            )
          ],
        ),
      ),
    );
  }
}