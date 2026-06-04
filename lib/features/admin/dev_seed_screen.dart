import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/seed_provider.dart';
import '../../shared/widgets/section_header.dart';

class DevSeedScreen extends ConsumerWidget {
  const DevSeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kDebugMode) {
      return const Scaffold(body: SizedBox.shrink());
    }

    final seedState = ref.watch(seedControllerProvider);

    ref.listen(seedControllerProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error.toString())));
      } else if (previous?.isLoading == true && next.hasValue) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demo verileri Firestore’a yüklendi.')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Debug Seed')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            const SectionHeader(
              title: 'Demo Veri Yükleme',
              subtitle: 'Tasks, rewards, recycling points ve leaderboard seed.',
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                'Bu işlem deterministik doküman ID’leriyle yazar. Aynı butona tekrar basmak yeni kopyalar oluşturmaz.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: seedState.isLoading
                  ? null
                  : () async {
                      try {
                        await ref
                            .read(seedControllerProvider.notifier)
                            .seedAll();
                      } on Object {
                        // Error SnackBar is handled by ref.listen above.
                      }
                    },
              icon: seedState.isLoading
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    )
                  : const Icon(Icons.cloud_upload_outlined),
              label: Text(
                seedState.isLoading
                    ? 'Yükleniyor...'
                    : 'Demo Verilerini Firestore’a Yükle',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
