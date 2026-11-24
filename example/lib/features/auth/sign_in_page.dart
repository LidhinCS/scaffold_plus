import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ui_plus/ui_plus.dart';
import 'package:ui_plus_example/cubit/app_shell_cubit.dart';

/// Lightweight sign-in surface used when the shell session is expired.
///
/// Prefer [PlusSessionExpired] inside [ScaffoldPlus] for gated tabs; this page
/// is available if the app wants a dedicated route later.
class SignInPage extends StatelessWidget {
  /// Creates the sign-in page.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldPlus<void>(
      appBar: AppBar(title: const Text('Sign in')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 56,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Welcome back',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Demo auth for the Pulse Tasks showcase. '
                  'No credentials required.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                PlusAsyncButton(
                  onPressed: () async {
                    await Future<void>.delayed(
                      const Duration(milliseconds: 400),
                    );
                    if (!context.mounted) {
                      return;
                    }
                    context.read<AppShellCubit>().signIn();
                    PlusSnackbar.success(message: 'Signed in');
                  },
                  child: const Text('Continue as demo user'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
