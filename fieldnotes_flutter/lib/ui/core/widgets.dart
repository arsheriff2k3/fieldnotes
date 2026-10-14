import 'package:flutter/material.dart';

import 'fieldnote_theme.dart';

enum FieldnoteNoticeKind { success, error, info }

OverlayEntry? _activeFieldnoteNotice;

/// Shows a floating, animated notice without changing the Scaffold layout.
///
/// Unlike a SnackBar, this does not move a center-docked action button or the
/// bottom navigation bar. Only one notice is shown at a time.
void showFieldnoteNotice(
  BuildContext context, {
  required String title,
  required String message,
  FieldnoteNoticeKind kind = FieldnoteNoticeKind.info,
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  _activeFieldnoteNotice?.remove();

  late final OverlayEntry entry;
  var removed = false;
  void remove() {
    if (removed) return;
    removed = true;
    entry.remove();
    if (identical(_activeFieldnoteNotice, entry)) {
      _activeFieldnoteNotice = null;
    }
  }

  entry = OverlayEntry(
    builder: (_) => _FieldnoteNotice(
      title: title,
      message: message,
      kind: kind,
      onDismissed: remove,
    ),
  );
  _activeFieldnoteNotice = entry;
  overlay.insert(entry);
}

class _FieldnoteNotice extends StatefulWidget {
  const _FieldnoteNotice({
    required this.title,
    required this.message,
    required this.kind,
    required this.onDismissed,
  });

  final String title;
  final String message;
  final FieldnoteNoticeKind kind;
  final VoidCallback onDismissed;

  @override
  State<_FieldnoteNotice> createState() => _FieldnoteNoticeState();
}

class _FieldnoteNoticeState extends State<_FieldnoteNotice>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 360),
    reverseDuration: const Duration(milliseconds: 220),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
    Future<void>.delayed(
      Duration(seconds: widget.kind == FieldnoteNoticeKind.error ? 6 : 4),
      _dismiss,
    );
  }

  Future<void> _dismiss() async {
    if (!mounted || _controller.status == AnimationStatus.reverse) return;
    await _controller.reverse();
    if (mounted) widget.onDismissed();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.fieldnoteColors;
    final (color, background, icon) = switch (widget.kind) {
      FieldnoteNoticeKind.success => (
        c.forest,
        c.successSurface,
        Icons.check_circle_rounded,
      ),
      FieldnoteNoticeKind.error => (
        c.errorAccent,
        c.errorSurface,
        Icons.error_rounded,
      ),
      FieldnoteNoticeKind.info => (
        c.ink,
        c.infoSurface,
        Icons.info_rounded,
      ),
    };

    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    );
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -1.2),
                end: Offset.zero,
              ).animate(curved),
              child: FadeTransition(
                opacity: _controller,
                child: Material(
                  color: Colors.transparent,
                  child: Semantics(
                    liveRegion: true,
                    container: true,
                    label: '${widget.title}. ${widget.message}',
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: color.withValues(alpha: .2)),
                        boxShadow: [
                          BoxShadow(
                            color: c.shadow.withValues(alpha: .18),
                            blurRadius: 28,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: .12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(icon, color: color, size: 22),
                            ),
                            const SizedBox(width: FieldnoteSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          color: color,
                                          fontWeight: FontWeight.w900,
                                        ),
                                  ),
                                  const SizedBox(height: FieldnoteSpacing.xxs),
                                  Text(
                                    widget.message,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: c.ink,
                                          height: 1.35,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: MaterialLocalizations.of(
                                context,
                              ).closeButtonTooltip,
                              onPressed: _dismiss,
                              visualDensity: VisualDensity.compact,
                              icon: Icon(Icons.close, color: color, size: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

abstract final class FieldnoteSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double fieldGap = md;
  static const double sectionGap = lg;
  static const double cardPadding = md;

  static EdgeInsets sheetPadding(
    BuildContext context, {
    double top = xs,
    double bottom = lg,
  }) => EdgeInsets.fromLTRB(
    pageGutter(context),
    top,
    pageGutter(context),
    bottom,
  );

  static double pageGutter(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 600) return 20;
    if (width < 1000) return 28;
    return 36;
  }
}

/// Consistent dialog gutters, scrolling content and separated actions.
AlertDialog fieldnoteDialog({
  required Widget title,
  Widget? content,
  List<Widget>? actions,
  ShapeBorder? shape,
}) => AlertDialog(
  title: title,
  content: content,
  actions: actions,
  shape: shape,
  scrollable: true,
  insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
  titlePadding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
  contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
  actionsPadding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
  actionsOverflowButtonSpacing: FieldnoteSpacing.sm,
  buttonPadding: const EdgeInsets.symmetric(horizontal: FieldnoteSpacing.xxs),
);

/// Every sheet uses the same safe area and keyboard policy. The keyboard
/// reduces the sheet's constraints, so draggable and scrolling children stay
/// usable without adding a second keyboard inset inside individual forms.
Future<T?> showFieldnoteBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  bool useSafeArea = true,
  bool showDragHandle = true,
}) => showModalBottomSheet<T>(
  context: context,
  isScrollControlled: isScrollControlled,
  useSafeArea: useSafeArea,
  showDragHandle: showDragHandle,
  builder: (sheetContext) => AnimatedPadding(
    duration: const Duration(milliseconds: 180),
    curve: Curves.easeOut,
    padding: EdgeInsets.only(
      bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
    ),
    child: SafeArea(
      top: false,
      child: Builder(
        builder: (safeContext) => MediaQuery.removeViewInsets(
          context: safeContext,
          removeBottom: true,
          child: Builder(builder: builder),
        ),
      ),
    ),
  ),
);

/// Paired actions stack when labels need more room. Expanded children remain
/// expanded in a row; in a column they become naturally sized full-width buttons.
class FieldnoteActionRow extends StatelessWidget {
  const FieldnoteActionRow({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = MediaQuery.textScalerOf(context).scale(16) / 16;
      if (constraints.maxWidth >= 360 && scale <= 1.3) {
        return Row(children: children);
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final child in children)
            if (child is SizedBox && child.child == null)
              const SizedBox(height: FieldnoteSpacing.sm)
            else if (child is Flexible)
              child.child
            else
              child,
        ],
      );
    },
  );
}

class FieldnoteSectionTab {
  const FieldnoteSectionTab(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// Compact, swipeable section tabs shared by sponsor and volunteer screens.
class FieldnoteSectionTabs extends StatelessWidget {
  const FieldnoteSectionTabs({
    super.key,
    required this.tabs,
    this.compact = false,
  });

  final List<FieldnoteSectionTab> tabs;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = context.fieldnoteColors;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: FieldnoteSpacing.pageGutter(context),
      ),
      child: Material(
        color: c.mist,
        borderRadius: BorderRadius.circular(compact ? 14 : 18),
        clipBehavior: Clip.antiAlias,
        child: TabBar(
          isScrollable: false,
          labelPadding: compact
              ? const EdgeInsets.symmetric(horizontal: 8)
              : null,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.all(3),
          indicator: BoxDecoration(
            color: c.forestFill,
            borderRadius: BorderRadius.circular(compact ? 11 : 15),
          ),
          dividerColor: Colors.transparent,
          labelColor: c.onFill,
          unselectedLabelColor: c.ink,
          labelStyle: const TextStyle(
            fontSize: 12,
            height: 1,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            height: 1,
            fontWeight: FontWeight.w700,
          ),
          tabs: [
            for (final tab in tabs)
              if (compact)
                Tab(
                  height: 46,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (MediaQuery.textScalerOf(context).scale(1) <= 1.3) ...[
                        Icon(tab.icon, size: 17),
                        const SizedBox(width: FieldnoteSpacing.xs),
                      ],
                      Flexible(
                        child: Text(
                          tab.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Tab(
                  height: 54,
                  iconMargin: const EdgeInsets.only(bottom: 3),
                  icon: Icon(tab.icon, size: 18),
                  text: tab.label,
                ),
          ],
        ),
      ),
    );
  }
}

class FieldnotePageList extends StatelessWidget {
  const FieldnotePageList({
    super.key,
    required this.children,
    this.top = FieldnoteSpacing.lg,
    this.bottom = FieldnoteSpacing.xl,
    this.maxWidth = 1360,
    this.shrinkWrap = false,
    this.controller,
  });

  final List<Widget> children;
  final double top;
  final double bottom;
  final double maxWidth;
  final bool shrinkWrap;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    final gutter = FieldnoteSpacing.pageGutter(context);
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const AlwaysScrollableScrollPhysics(),
          controller: controller,
          shrinkWrap: shrinkWrap,
          padding: EdgeInsets.fromLTRB(gutter, top, gutter, bottom),
          children: children,
        ),
      ),
    );
  }
}

class ResponsiveCardGrid extends StatelessWidget {
  const ResponsiveCardGrid({
    super.key,
    required this.children,
    this.minimumItemWidth = 360,
    this.spacing = FieldnoteSpacing.md,
  });

  final List<Widget> children;
  final double minimumItemWidth;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < minimumItemWidth * 2 + spacing
            ? 1
            : (constraints.maxWidth / minimumItemWidth).floor().clamp(1, 3);
        final itemWidth =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}

/// The shared text input used by FieldNote forms. Keeping this as a TextField
/// subtype preserves the familiar Flutter API while centralising its sizing.
class FieldnoteTextField extends TextField {
  const FieldnoteTextField({
    super.key,
    super.controller,
    super.focusNode,
    super.decoration,
    super.keyboardType,
    super.textInputAction,
    super.textCapitalization = TextCapitalization.none,
    super.style,
    super.textAlign,
    super.autofocus,
    super.readOnly,
    super.enabled,
    super.minLines,
    super.maxLines = 1,
    super.maxLength,
    super.onChanged,
    super.onSubmitted,
    super.onTap,
    super.obscureText,
  });
}

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
  });

  final Widget child;
  final EdgeInsets? padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.fieldnoteColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? c.paper,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: c.ink.withValues(alpha: .08)),
        boxShadow: [
          BoxShadow(
            color: c.shadow.withValues(alpha: .05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding:
              padding ??
              EdgeInsets.all(
                MediaQuery.sizeOf(context).width < 600
                    ? FieldnoteSpacing.cardPadding
                    : FieldnoteSpacing.lg,
              ),
          child: child,
        ),
      ),
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.eyebrow,
    required this.title,
    this.description,
    this.trailing,
  });

  final String eyebrow;
  final String title;
  final String? description;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: context.fieldnoteColors.clay,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: FieldnoteSpacing.xxs),
        Text(
          title,
          style: MediaQuery.sizeOf(context).width < 600
              ? Theme.of(context).textTheme.headlineMedium
              : Theme.of(context).textTheme.headlineLarge,
        ),
        if (description != null) ...[
          const SizedBox(height: FieldnoteSpacing.xs),
          Text(description!, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ],
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (trailing != null && constraints.maxWidth < 650) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading,
              const SizedBox(height: FieldnoteSpacing.md),
              trailing!,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: heading),
            if (trailing != null) ...[
              const SizedBox(width: FieldnoteSpacing.md),
              trailing!,
            ],
          ],
        );
      },
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    // Callers pass light brand constants (often from pure helpers); map them
    // to the active brightness here.
    final color = context.fieldnoteColors.adapt(this.color);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: FieldnoteSpacing.xs),
          ],
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyPanel extends StatelessWidget {
  const EmptyPanel({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: FieldnoteSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 34, color: context.fieldnoteColors.moss),
              const SizedBox(height: FieldnoteSpacing.md),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: FieldnoteSpacing.xs),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
