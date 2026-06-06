import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final educationContentRepositoryProvider = Provider<EducationContentRepository>(
  (ref) => const EducationContentRepository(),
);

final educationContentProvider = FutureProvider<EducationContent>((ref) {
  return ref.watch(educationContentRepositoryProvider).load();
});

class EducationContentRepository {
  const EducationContentRepository({
    this.assetBundle,
    this.assetPath = 'assets/education/recycling_education.md',
  });

  final AssetBundle? assetBundle;
  final String assetPath;

  Future<EducationContent> load() async {
    try {
      final bundle = assetBundle ?? rootBundle;
      final markdown = await bundle.loadString(assetPath);
      final content = EducationMarkdownParser(markdown).parse();
      if (content.sections.isEmpty) return EducationContent.fallback();
      return content;
    } catch (_) {
      return EducationContent.fallback();
    }
  }
}

class EducationContent {
  const EducationContent({
    required this.title,
    required this.sections,
    required this.faqs,
  });

  final String title;
  final List<EducationSection> sections;
  final List<EducationFaq> faqs;

  List<EducationSection> get previewSections {
    final preferredTitles = [
      'Sıfır Atık Nedir?',
      'Geri Dönüşüm Neden Önemlidir?',
      'Atık Türleri ve Doğru Ayrıştırma',
    ];

    final preferred = <EducationSection>[];
    for (final title in preferredTitles) {
      final section = sections.where((section) => section.title == title);
      if (section.isNotEmpty) preferred.add(section.first);
    }

    if (preferred.length >= 3) return preferred.take(3).toList();
    return [...preferred, ...sections]
        .fold<List<EducationSection>>([], (unique, section) {
          if (!unique.any((item) => item.title == section.title)) {
            unique.add(section);
          }
          return unique;
        })
        .take(3)
        .toList();
  }

  factory EducationContent.fallback() {
    return const EducationContent(
      title: 'AtıkAvı Erzurum Eğitim İçeriği',
      sections: [
        EducationSection(
          title: 'Sıfır Atık Nedir?',
          blocks: [
            EducationBlock(
              type: EducationBlockType.paragraph,
              text:
                  'Sıfır atık, atığı oluşmadan azaltmayı, yeniden kullanmayı ve geri dönüştürülebilir malzemeleri doğru kutulara ulaştırmayı hedefler.',
            ),
          ],
        ),
        EducationSection(
          title: 'Geri Dönüşüm Neden Önemlidir?',
          blocks: [
            EducationBlock(
              type: EducationBlockType.paragraph,
              text:
                  'Geri dönüşüm doğal kaynakları korur, enerji tasarrufu sağlar ve Erzurum için daha temiz yaşam alanları oluşturur.',
            ),
          ],
        ),
        EducationSection(
          title: 'Atık Türleri ve Doğru Ayrıştırma',
          blocks: [
            EducationBlock(
              type: EducationBlockType.list,
              items: [
                'Plastik ve kağıt atıkları mavi kutuya at.',
                'Cam şişe ve kavanozları yeşil kutuya bırak.',
                'Pilleri özel pil toplama kutularına götür.',
              ],
            ),
          ],
        ),
      ],
      faqs: [
        EducationFaq(
          question: 'Plastik şişe nereye atılır?',
          answer: 'Temiz plastik şişeler mavi geri dönüşüm kutusuna atılır.',
        ),
      ],
    );
  }
}

class EducationSection {
  const EducationSection({required this.title, required this.blocks});

  final String title;
  final List<EducationBlock> blocks;

  String get summary {
    for (final block in blocks) {
      final source = block.text.trim().isNotEmpty
          ? block.text.trim()
          : block.items.isNotEmpty
          ? block.items.first.trim()
          : '';
      if (source.isNotEmpty) return _limit(source, 120);
    }
    return '';
  }
}

class EducationBlock {
  const EducationBlock({
    required this.type,
    this.text = '',
    this.items = const [],
  });

  final EducationBlockType type;
  final String text;
  final List<String> items;
}

enum EducationBlockType { subheading, paragraph, list }

class EducationFaq {
  const EducationFaq({required this.question, required this.answer});

  final String question;
  final String answer;
}

class EducationMarkdownParser {
  EducationMarkdownParser(this.markdown);

  final String markdown;

  EducationContent parse() {
    var title = 'AtıkAvı Erzurum Eğitim İçeriği';
    final sections = <EducationSection>[];
    final faqs = <EducationFaq>[];
    final lines = markdown.split('\n');

    String? currentTitle;
    final blocks = <EducationBlock>[];
    final paragraph = <String>[];
    final listItems = <String>[];
    var inCodeBlock = false;
    var inFaqSection = false;

    void flushParagraph() {
      if (paragraph.isEmpty) return;
      final text = paragraph.join(' ').trim();
      paragraph.clear();
      if (text.isEmpty) return;
      blocks.add(
        EducationBlock(
          type: EducationBlockType.paragraph,
          text: _cleanInlineMarkdown(text),
        ),
      );
    }

    void flushList() {
      if (listItems.isEmpty) return;
      blocks.add(
        EducationBlock(
          type: EducationBlockType.list,
          items: listItems.map(_cleanInlineMarkdown).toList(),
        ),
      );
      listItems.clear();
    }

    void flushSection() {
      flushParagraph();
      flushList();
      if (currentTitle == null || blocks.isEmpty) return;
      sections.add(
        EducationSection(title: currentTitle, blocks: List.of(blocks)),
      );
      blocks.clear();
    }

    for (var index = 0; index < lines.length; index++) {
      final rawLine = lines[index].trim();
      if (rawLine.startsWith('```')) {
        inCodeBlock = !inCodeBlock;
        continue;
      }
      if (inCodeBlock) continue;
      if (rawLine.isEmpty || rawLine == '---') {
        flushParagraph();
        flushList();
        continue;
      }
      if (rawLine.startsWith('>')) continue;

      if (rawLine.startsWith('# ')) {
        title = _cleanHeading(rawLine.substring(2));
        continue;
      }

      if (rawLine.startsWith('## ')) {
        flushSection();
        currentTitle = _cleanHeading(rawLine.substring(3));
        inFaqSection = currentTitle.contains('Sık Sorulan Sorular');
        continue;
      }

      if (inFaqSection) {
        final faq = _parseFaq(lines, index);
        if (faq != null) {
          faqs.add(faq.item1);
          index = faq.item2;
        }
        continue;
      }

      if (rawLine.startsWith('### ')) {
        flushParagraph();
        flushList();
        blocks.add(
          EducationBlock(
            type: EducationBlockType.subheading,
            text: _cleanHeading(rawLine.substring(4)),
          ),
        );
        continue;
      }

      if (rawLine.startsWith('- ')) {
        flushParagraph();
        listItems.add(rawLine.substring(2));
        continue;
      }

      paragraph.add(rawLine);
    }

    flushSection();

    return EducationContent(title: title, sections: sections, faqs: faqs);
  }

  ({EducationFaq item1, int item2})? _parseFaq(List<String> lines, int index) {
    final questionLine = lines[index].trim();
    final questionMatch = RegExp(
      r'^\*\*S\d+:\s*(.+?)\*\*$',
    ).firstMatch(questionLine);
    if (questionMatch == null) return null;

    for (var nextIndex = index + 1; nextIndex < lines.length; nextIndex++) {
      final answerLine = lines[nextIndex].trim();
      if (answerLine.isEmpty || answerLine == '---') continue;
      if (!answerLine.startsWith('C:')) return null;
      return (
        item1: EducationFaq(
          question: _cleanInlineMarkdown(questionMatch.group(1)!),
          answer: _cleanInlineMarkdown(answerLine.substring(2).trim()),
        ),
        item2: nextIndex,
      );
    }
    return null;
  }
}

String _cleanHeading(String value) {
  return _cleanInlineMarkdown(
    value.replaceFirst(RegExp(r'^\d+\.\s*'), '').trim(),
  );
}

String _cleanInlineMarkdown(String value) {
  return value
      .replaceAllMapped(
        RegExp(r'\*\*(.*?)\*\*'),
        (match) => match.group(1) ?? '',
      )
      .replaceAll(RegExp(r'[_`]+'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

String _limit(String value, int maxLength) {
  if (value.length <= maxLength) return value;
  final shortened = value.substring(0, maxLength).trimRight();
  return '$shortened...';
}
