import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../data/education_content_repository.dart';
import 'education_detail_sheet.dart';

class EducationCardDeck extends StatefulWidget {
  const EducationCardDeck({required this.content, super.key});

  final EducationContent content;

  @override
  State<EducationCardDeck> createState() => _EducationCardDeckState();
}

class _EducationCardDeckState extends State<EducationCardDeck> {
  static const _animationDuration = Duration(milliseconds: 260);

  late List<EducationDeckItem> _items;
  var _activeIndex = 0;
  Offset _dragOffset = Offset.zero;
  Offset _exitOffset = Offset.zero;
  int? _exitingIndex;
  Timer? _clearExitTimer;

  @override
  void initState() {
    super.initState();
    _items = _buildItems(widget.content);
  }

  @override
  void didUpdateWidget(EducationCardDeck oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content) {
      _items = _buildItems(widget.content);
      _activeIndex = 0;
      _dragOffset = Offset.zero;
      _exitingIndex = null;
      _exitOffset = Offset.zero;
    }
  }

  @override
  void dispose() {
    _clearExitTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return const SizedBox.shrink();
    }

    final activeItem = _items[_activeIndex];

    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final exitDistance = math.max(constraints.maxWidth, 320.0);

              return Stack(
                alignment: Alignment.topCenter,
                children: [
                  for (var depth = 2; depth >= 0; depth--)
                    _DeckLayer(
                      key: ValueKey(
                        'deck-${_itemIndexAt(depth)}-${_exitingIndex ?? -1}',
                      ),
                      depth: depth,
                      item: _items[_itemIndexAt(depth)],
                      totalCount: _items.length,
                      currentPosition: _itemIndexAt(depth) + 1,
                      dragOffset: depth == 0 ? _dragOffset : Offset.zero,
                      onTap: depth == 0 ? () => _advance() : null,
                      onDetails: depth == 0
                          ? () => EducationDetailSheet.show(context, activeItem)
                          : null,
                      onPanUpdate: depth == 0 ? _handlePanUpdate : null,
                      onPanEnd: depth == 0
                          ? (details) => _handlePanEnd(details, exitDistance)
                          : null,
                    ),
                  if (_exitingIndex != null)
                    _ExitingDeckLayer(
                      item: _items[_exitingIndex!],
                      offset: _exitOffset,
                    ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${_activeIndex + 1} / ${_items.length}',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        _DeckDots(activeIndex: _activeIndex, itemCount: _items.length),
      ],
    );
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() => _dragOffset += details.delta);
  }

  void _handlePanEnd(DragEndDetails details, double exitDistance) {
    final velocity = details.velocity.pixelsPerSecond;
    final shouldAdvance =
        _dragOffset.distance > 56 ||
        velocity.dx.abs() > 360 ||
        velocity.dy.abs() > 360;

    if (!shouldAdvance) {
      setState(() => _dragOffset = Offset.zero);
      return;
    }

    final direction = _swipeDirection(velocity, _dragOffset);
    _advance(exitOffset: direction * exitDistance);
  }

  void _advance({Offset? exitOffset}) {
    if (_items.length <= 1 || _exitingIndex != null) return;

    _clearExitTimer?.cancel();
    final currentIndex = _activeIndex;
    final targetOffset = exitOffset ?? const Offset(0, -360);

    setState(() {
      _exitingIndex = currentIndex;
      _activeIndex = (_activeIndex + 1) % _items.length;
      _dragOffset = Offset.zero;
      _exitOffset = Offset.zero;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _exitOffset = targetOffset);
    });

    _clearExitTimer = Timer(_animationDuration, () {
      if (!mounted) return;
      setState(() {
        _exitingIndex = null;
        _exitOffset = Offset.zero;
      });
    });
  }

  Offset _swipeDirection(Offset velocity, Offset dragOffset) {
    final source = velocity.distance > 0 ? velocity : dragOffset;
    if (source.distance == 0) return const Offset(0, -1);
    return source / source.distance;
  }

  int _itemIndexAt(int depth) {
    return (_activeIndex + depth) % _items.length;
  }
}

class _DeckLayer extends StatelessWidget {
  const _DeckLayer({
    required this.depth,
    required this.item,
    required this.totalCount,
    required this.currentPosition,
    required this.dragOffset,
    required this.onTap,
    required this.onDetails,
    required this.onPanUpdate,
    required this.onPanEnd,
    super.key,
  });

  final int depth;
  final EducationDeckItem item;
  final int totalCount;
  final int currentPosition;
  final Offset dragOffset;
  final VoidCallback? onTap;
  final VoidCallback? onDetails;
  final GestureDragUpdateCallback? onPanUpdate;
  final GestureDragEndCallback? onPanEnd;

  @override
  Widget build(BuildContext context) {
    final top = depth * 22.0 + (depth == 0 ? dragOffset.dy : 0);
    final horizontalInset = depth * 12.0;
    final scale = 1 - (depth * 0.055);
    final opacity = 1 - (depth * 0.22);

    return AnimatedPositioned(
      duration: _EducationCardDeckState._animationDuration,
      curve: Curves.easeOutCubic,
      top: top,
      left: horizontalInset + (depth == 0 ? dragOffset.dx : 0),
      right: horizontalInset - (depth == 0 ? dragOffset.dx : 0),
      bottom: depth * 8.0,
      child: AnimatedScale(
        duration: _EducationCardDeckState._animationDuration,
        curve: Curves.easeOutCubic,
        scale: scale,
        child: AnimatedOpacity(
          duration: _EducationCardDeckState._animationDuration,
          opacity: opacity,
          child: EducationDeckCard(
            item: item,
            totalCount: totalCount,
            currentPosition: currentPosition,
            active: depth == 0,
            onTap: onTap,
            onDetails: onDetails,
            onPanUpdate: onPanUpdate,
            onPanEnd: onPanEnd,
          ),
        ),
      ),
    );
  }
}

class _ExitingDeckLayer extends StatelessWidget {
  const _ExitingDeckLayer({required this.item, required this.offset});

  final EducationDeckItem item;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: _EducationCardDeckState._animationDuration,
      curve: Curves.easeInCubic,
      top: offset.dy,
      left: offset.dx,
      right: -offset.dx,
      bottom: 0,
      child: AnimatedOpacity(
        duration: _EducationCardDeckState._animationDuration,
        opacity: offset == Offset.zero ? 1 : 0,
        child: EducationDeckCard(
          item: item,
          totalCount: 1,
          currentPosition: 1,
          active: true,
        ),
      ),
    );
  }
}

class EducationDeckCard extends StatelessWidget {
  const EducationDeckCard({
    required this.item,
    required this.totalCount,
    required this.currentPosition,
    required this.active,
    this.onTap,
    this.onDetails,
    this.onPanUpdate,
    this.onPanEnd,
    super.key,
  });

  final EducationDeckItem item;
  final int totalCount;
  final int currentPosition;
  final bool active;
  final VoidCallback? onTap;
  final VoidCallback? onDetails;
  final GestureDragUpdateCallback? onPanUpdate;
  final GestureDragEndCallback? onPanEnd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: active
              ? AppColors.surfaceContainerLowest
              : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: active ? 0.34 : 0.16),
              blurRadius: active ? 24 : 14,
              offset: Offset(0, active ? 14 : 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    item.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '$currentPosition / $totalCount',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.title.copyWith(
                fontSize: 23,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item.summary,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 14),
            for (final highlight in item.highlights.take(3)) ...[
              _HighlightRow(text: highlight),
              const SizedBox(height: 8),
            ],
            const Spacer(),
            Row(
              children: [
                if (onDetails != null)
                  TextButton.icon(
                    onPressed: onDetails,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: EdgeInsets.zero,
                      textStyle: AppTextStyles.label,
                    ),
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text('Detayları Gör'),
                  ),
                const Spacer(),
                Text(
                  'Sonraki Bilgi',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.swipe, size: 18, color: AppColors.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HighlightRow extends StatelessWidget {
  const _HighlightRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle, size: 17, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _DeckDots extends StatelessWidget {
  const _DeckDots({required this.activeIndex, required this.itemCount});

  final int activeIndex;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final visibleCount = math.min(itemCount, 8);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var index = 0; index < visibleCount; index++) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: index == activeIndex % visibleCount ? 18 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: index == activeIndex % visibleCount
                  ? AppColors.primary
                  : AppColors.outlineVariant,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          if (index != visibleCount - 1) const SizedBox(width: 5),
        ],
      ],
    );
  }
}

List<EducationDeckItem> _buildItems(EducationContent content) {
  return [
    ...content.sections.map(EducationSectionDeckItem.new),
    ...content.faqs.take(8).map(EducationFaqDeckItem.new),
  ];
}
