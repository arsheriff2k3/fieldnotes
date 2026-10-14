import 'package:flutter/material.dart';

import '../../core/fieldnote_theme.dart';

@immutable
class WorkspaceDestination {
  const WorkspaceDestination(
    this.label,
    this.icon,
    this.selectedIcon, {
    this.compactLabel,
  });
  final String label;
  final String? compactLabel;
  final IconData icon;
  final IconData selectedIcon;
}

/// Shared, safe-area-aware navigation for both account roles.
class WorkspaceBottomNavigation extends StatelessWidget {
  const WorkspaceBottomNavigation({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    this.dockedActionIndex,
  });
  final List<WorkspaceDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  // Reserves the icon area for the Sponsor's existing microphone FAB.
  final int? dockedActionIndex;

  @override
  Widget build(BuildContext context) {
    final c = context.fieldnoteColors;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 220);
    final height =
        (dockedActionIndex == null ? 36 : 40) +
        MediaQuery.textScalerOf(context).scale(11) * 2.4;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.paper,
        border: Border(top: BorderSide(color: c.ink.withValues(alpha: .08))),
        boxShadow: [
          BoxShadow(
            color: c.shadow.withValues(alpha: .045),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              child: SizedBox(
                height: height,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth =
                        constraints.maxWidth / destinations.length;
                    return Stack(
                      children: [
                        AnimatedPositionedDirectional(
                          duration: duration,
                          curve: Curves.easeOutCubic,
                          start: selectedIndex * itemWidth + 4,
                          top: 2,
                          bottom: 2,
                          width: itemWidth - 8,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: c.mist.withValues(alpha: .65),
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            for (final (index, item) in destinations.indexed)
                              Expanded(
                                child: Semantics(
                                  label: item.label,
                                  button: true,
                                  selected: selectedIndex == index,
                                  onTap: () => onSelected(index),
                                  child: Tooltip(
                                    message: item.label,
                                    excludeFromSemantics: true,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        key: ValueKey('workspace-nav-$index'),
                                        borderRadius: BorderRadius.circular(14),
                                        onTap: () {
                                          if (selectedIndex != index) {
                                            onSelected(index);
                                          }
                                        },
                                        excludeFromSemantics: true,
                                        child: ExcludeSemantics(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 3,
                                              vertical: 3,
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                if (index == dockedActionIndex)
                                                  const SizedBox(
                                                    width: 34,
                                                    height: 30,
                                                  )
                                                else
                                                  AnimatedContainer(
                                                    duration: duration,
                                                    curve: Curves.easeOutCubic,
                                                    width: 34,
                                                    height: 26,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          selectedIndex == index
                                                          ? c.forestFill
                                                          : Colors.transparent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                    child: Icon(
                                                      selectedIndex == index
                                                          ? item.selectedIcon
                                                          : item.icon,
                                                      size: 20,
                                                      color:
                                                          selectedIndex == index
                                                          ? c.onFill
                                                          : c.ink.withValues(
                                                              alpha: .68,
                                                            ),
                                                    ),
                                                  ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  item.compactLabel ??
                                                      item.label,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelMedium
                                                      ?.copyWith(
                                                        fontSize: 11,
                                                        height: 1.2,
                                                        color:
                                                            selectedIndex ==
                                                                index
                                                            ? c.forest
                                                            : c.ink.withValues(
                                                                alpha: .72,
                                                              ),
                                                        fontWeight:
                                                            selectedIndex ==
                                                                index
                                                            ? FontWeight.w700
                                                            : FontWeight.w500,
                                                      ),
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
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
