import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAction = ref.watch(authControllerProvider);
    final isLoading = authAction.isLoading;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryLight],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: 132,
                  height: 132,
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.92),
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 28,
                        offset: Offset(0, 14),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.recycling,
                    color: AppColors.primary,
                    size: 72,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'AtıkAvı Erzurum',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.display.copyWith(
                    color: AppColors.textOnPrimary,
                    fontSize: 38,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Atığını dönüştür, puanını kazan, Erzurum’u temizle.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.subtitle.copyWith(
                    color: AppColors.textOnPrimary.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 36),
                FilledButton.icon(
                  onPressed: isLoading
                      ? null
                      : () async {
                          try {
                            await ref
                                .read(authControllerProvider.notifier)
                                .signInWithGoogle();
                          } on Object catch (error) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(error.toString())),
                            );
                          }
                        },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    backgroundColor: AppColors.surface,
                    foregroundColor: AppColors.primary,
                  ),
                  icon: isLoading
                      ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : const Icon(Icons.g_mobiledata, size: 30),
                  label: Text(
                    isLoading ? 'Giriş yapılıyor...' : 'Google ile Giriş Yap',
                  ),
                ),
                const Spacer(),
                const _NatureFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NatureFooter extends StatelessWidget {
  const _NatureFooter();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 118,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primaryDark.withValues(alpha: 0.42),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(48),
                ),
              ),
            ),
          ),
          for (final tree in const [
            (24.0, 54.0),
            (84.0, 82.0),
            (168.0, 66.0),
            (246.0, 90.0),
          ])
            Positioned(
              left: tree.$1,
              bottom: 28,
              child: Icon(
                Icons.park,
                color: AppColors.textOnPrimary.withValues(alpha: 0.86),
                size: tree.$2,
              ),
            ),
          Positioned(
            right: 18,
            bottom: 52,
            child: Icon(
              Icons.ac_unit,
              color: AppColors.winterLight.withValues(alpha: 0.86),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
