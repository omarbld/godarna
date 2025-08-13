import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: Text(tr('profile.title'))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (auth.profile != null) ...[
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(auth.profile!.fullName ?? auth.profile!.email),
                subtitle: Text(tr('profile.role', args: [auth.profile!.role])),
              ),
              const Divider(),
            ],
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(tr('common.switch_language')),
              onTap: () {
                final next = context.locale.languageCode == 'ar' ? const Locale('fr', 'FR') : const Locale('ar', 'MA');
                context.setLocale(next);
              },
            ),
            const Spacer(),
            if (auth.profile != null)
              ElevatedButton.icon(
                onPressed: () => ref.read(authProvider.notifier).signOut(),
                icon: const Icon(Icons.logout),
                label: Text(tr('auth.sign_out')),
              ),
          ],
        ),
      ),
    );
  }
}