import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../data/education_content_repository.dart';
import 'education_faq_card.dart';
import 'education_section_card.dart';

class EducationDetailSheet extends StatelessWidget {
  const EducationDetailSheet({required this.item, super.key});

  final EducationDeckItem item;

  static Future<void> show(BuildContext context, EducationDeckItem item) {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => EducationDetailSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.78;

    return SizedBox(
      height: maxHeight,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          4,
          16,
          MediaQuery.paddingOf(context).bottom + 20,
        ),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: AppTextStyles.title.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Kapat',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 10),
          switch (item) {
            EducationSectionDeckItem(:final section) => EducationSectionCard(
              section: section,
            ),
            EducationFaqDeckItem(:final faq) => EducationFaqCard(faq: faq),
          },
        ],
      ),
    );
  }
}

sealed class EducationDeckItem {
  const EducationDeckItem();

  String get category;
  String get title;
  String get summary;
  List<String> get highlights;
}

class EducationSectionDeckItem extends EducationDeckItem {
  const EducationSectionDeckItem(this.section);

  final EducationSection section;

  @override
  String get category => 'Eğitim Bölümü';

  @override
  String get title => section.title;

  @override
  String get summary => section.summary;

  @override
  List<String> get highlights {
    final items = <String>[];
    for (final block in section.blocks) {
      if (block.type == EducationBlockType.subheading) {
        items.add(block.text);
      } else if (block.type == EducationBlockType.paragraph) {
        items.add(_limit(block.text, 86));
      } else {
        items.addAll(block.items.map((item) => _limit(item, 86)));
      }
      if (items.length >= 3) break;
    }
    return items.take(3).toList();
  }
}

class EducationFaqDeckItem extends EducationDeckItem {
  const EducationFaqDeckItem(this.faq);

  final EducationFaq faq;

  @override
  String get category => 'Sık Sorulan Soru';

  @override
  String get title => faq.question;

  @override
  String get summary => _limit(faq.answer, 130);

  @override
  List<String> get highlights => const ['Yanıtı detaylarda incele.'];
}

String _limit(String value, int maxLength) {
  if (value.length <= maxLength) return value;
  return '${value.substring(0, maxLength).trimRight()}...';
}
