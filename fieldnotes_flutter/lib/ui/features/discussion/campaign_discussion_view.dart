import 'dart:async';
import 'dart:math' as math;

import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../data/repositories/fieldnote_repository.dart';
import '../../../l10n/l10n.dart';
import '../../core/error_messages.dart';
import 'campaign_discussion_model.dart';
import 'campaign_discussion_visibility.dart';

class CampaignDiscussionView extends StatefulWidget {
  const CampaignDiscussionView({
    super.key,
    required this.campaign,
    required this.repository,
    required this.currentUserId,
  });
  final Campaign campaign;
  final FieldnoteRepository repository;
  final UuidValue? currentUserId;

  @override
  State<CampaignDiscussionView> createState() => _CampaignDiscussionViewState();
}

class _CampaignDiscussionViewState extends State<CampaignDiscussionView>
    with WidgetsBindingObserver {
  final _text = TextEditingController();
  final _scroll = ScrollController();
  final _focus = FocusNode();
  final _animatedIds = <int>{};
  late final CampaignDiscussionModel _model;
  bool _historyReady = false;
  int _latestId = 0;
  int _unread = 0;
  Timer? _readDebounce;
  int _readThrough = 0;
  double? _anchorExtent;
  double? _anchorOffset;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _model = CampaignDiscussionModel(widget.repository, widget.campaign.id!)
      ..addListener(_changed)
      ..start();
    _scroll.addListener(_scrolled);
    _focus.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.isCurrentOf(context) ?? true) {
      CampaignDiscussionVisibility.show(this, widget.campaign.id!);
      _acknowledge();
    } else {
      CampaignDiscussionVisibility.hide(this);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _acknowledge();
  }

  void _acknowledge() {
    if (!mounted ||
        !(ModalRoute.isCurrentOf(context) ?? true) ||
        (WidgetsBinding.instance.lifecycleState != null &&
            WidgetsBinding.instance.lifecycleState !=
                AppLifecycleState.resumed)) {
      return;
    }
    final messages = _model.messages;
    if (messages.isEmpty || messages.first.id! <= _readThrough) return;
    final through = messages.first.id!;
    _readDebounce?.cancel();
    _readDebounce = Timer(const Duration(milliseconds: 150), () async {
      if (!mounted ||
          !(ModalRoute.isCurrentOf(context) ?? true) ||
          WidgetsBinding.instance.lifecycleState == AppLifecycleState.paused ||
          WidgetsBinding.instance.lifecycleState ==
              AppLifecycleState.inactive) {
        return;
      }
      try {
        await widget.repository.markCampaignChatRead(
          widget.campaign.id!,
          through,
        );
        _readThrough = through;
      } catch (_) {
        /* Retried on the next room event or reconnection. */
      }
    });
  }

  void _changed() {
    final messages = _model.messages;
    if (!_model.loading && !_historyReady) {
      _historyReady = true;
      _latestId = messages.isEmpty ? 0 : messages.first.id!;
    } else if (_historyReady &&
        messages.isNotEmpty &&
        messages.first.id! > _latestId) {
      final incoming = messages.where((m) => m.id! > _latestId).toList();
      _animatedIds.addAll(incoming.map((m) => m.id!));
      _latestId = messages.first.id!;
      final nearBottom = !_scroll.hasClients || _scroll.offset < 100;
      if (nearBottom ||
          incoming.any((m) => m.senderAuthUserId == widget.currentUserId)) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _toLatest());
      } else {
        _unread += incoming.length;
        if (_anchorExtent == null && _scroll.hasClients) {
          _anchorExtent = _scroll.position.maxScrollExtent;
          _anchorOffset = _scroll.offset;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _scroll.hasClients && _anchorExtent != null) {
              final change = _scroll.position.maxScrollExtent - _anchorExtent!;
              _scroll.jumpTo(
                (_anchorOffset! + change).clamp(
                  0,
                  _scroll.position.maxScrollExtent,
                ),
              );
            }
            _anchorExtent = null;
            _anchorOffset = null;
          });
        }
      }
    }
    _acknowledge();
    if (mounted) setState(() {});
  }

  void _scrolled() {
    if (_scroll.offset < 40 && _unread > 0) setState(() => _unread = 0);
  }

  void _toLatest() {
    if (!mounted || !_scroll.hasClients) return;
    if (_unread != 0) setState(() => _unread = 0);
    if (MediaQuery.disableAnimationsOf(context)) {
      _scroll.jumpTo(0);
    } else {
      unawaited(
        _scroll.animateTo(
          0,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
        ),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _readDebounce?.cancel();
    CampaignDiscussionVisibility.hide(this);
    _model.removeListener(_changed);
    _model.dispose();
    _scroll.dispose();
    _focus.dispose();
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final draft = _text.text;
    if (draft.trim().isEmpty) return;
    final sent = await _model.send(draft);
    if (!mounted) return;
    if (sent) {
      if (_text.text == draft) _text.clear();
      unawaited(HapticFeedback.selectionClick());
      _toLatest();
    } else if (_model.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userMessageFor(_model.error!, context: context)),
        ),
      );
    }
  }

  void _roomInfo() {
    final l10n = context.l10n;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.campaign.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(l10n.campaignDiscussionDescription),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.place_outlined, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(widget.campaign.locationName)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _dayLabel(DateTime date) {
    final local = date.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(local.year, local.month, local.day);
    if (day == today) return context.l10n.campaignDiscussionToday;
    if (day == DateTime(today.year, today.month, today.day - 1)) {
      return context.l10n.campaignDiscussionYesterday;
    }
    return DateFormat.yMMMd(context.localeTag).format(local);
  }

  bool _sameDay(DateTime a, DateTime b) {
    a = a.toLocal();
    b = b.toLocal();
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = _ChatPalette(Theme.of(context).brightness);
    final messages = _model.messages;
    final status = _model.accessDenied
        ? l10n.campaignDiscussionUnavailable
        : !_model.connected
        ? l10n.campaignDiscussionConnecting
        : _model.readOnly
        ? l10n.campaignDiscussionArchived
        : l10n.campaignDiscussionConnected;
    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.surface,
        iconTheme: IconThemeData(color: palette.ink),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 72,
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: palette.accent.withValues(alpha: .09),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.forum_outlined, size: 21, color: palette.ink),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.campaignDiscussionTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: palette.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    l10n.campaignDiscussionTeam,
                    style: TextStyle(fontSize: 12, color: palette.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: l10n.campaignDiscussionInfo,
            onPressed: _roomInfo,
            icon: Icon(Icons.info_outline_rounded, color: palette.muted),
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: palette.line),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: Column(
              children: [
                Container(
                  color: palette.surface,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.campaign.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: palette.ink,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Semantics(
                        liveRegion: true,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedContainer(
                              duration: MediaQuery.disableAnimationsOf(context)
                                  ? Duration.zero
                                  : const Duration(milliseconds: 200),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _model.connected
                                    ? palette.accent
                                    : palette.muted,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              status,
                              style: TextStyle(
                                fontSize: 11,
                                color: palette.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (_model.error != null &&
                    !_model.accessDenied &&
                    _model.connected)
                  Material(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        userMessageFor(_model.error!, context: context),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: _model.loading
                            ? Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: palette.accent,
                                  ),
                                ),
                              )
                            : messages.isEmpty
                            ? _EmptyDiscussion(
                                palette: palette,
                                denied: _model.accessDenied,
                              )
                            : ListView.builder(
                                controller: _scroll,
                                reverse: true,
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior.onDrag,
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  20,
                                  16,
                                  16,
                                ),
                                itemCount:
                                    messages.length + (_model.hasOlder ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == messages.length) {
                                    return Center(
                                      child: TextButton(
                                        onPressed: _model.loadingOlder
                                            ? null
                                            : _model.loadOlder,
                                        child: _model.loadingOlder
                                            ? const SizedBox(
                                                width: 18,
                                                height: 18,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : Text(
                                                l10n.campaignDiscussionOlder,
                                              ),
                                      ),
                                    );
                                  }
                                  final message = messages[index];
                                  final older = index + 1 < messages.length
                                      ? messages[index + 1]
                                      : null;
                                  final newDay =
                                      older == null ||
                                      !_sameDay(
                                        message.createdAt,
                                        older.createdAt,
                                      );
                                  final grouped =
                                      older != null &&
                                      !newDay &&
                                      older.senderAuthUserId ==
                                          message.senderAuthUserId &&
                                      message.createdAt
                                              .difference(older.createdAt)
                                              .abs() <
                                          const Duration(minutes: 5);
                                  return _MessageEntrance(
                                    key: ValueKey(message.id),
                                    animate: _animatedIds.remove(message.id),
                                    child: Column(
                                      children: [
                                        if (newDay)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 18,
                                            ),
                                            child: Text(
                                              _dayLabel(message.createdAt),
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: .3,
                                                color: palette.muted,
                                              ),
                                            ),
                                          ),
                                        _MessageBubble(
                                          message: message,
                                          mine:
                                              message.senderAuthUserId ==
                                              widget.currentUserId,
                                          grouped: grouped,
                                          palette: palette,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                      if (_unread > 0)
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: palette.accent,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(48, 44),
                              ),
                              onPressed: _toLatest,
                              icon: const Icon(
                                Icons.arrow_downward_rounded,
                                size: 16,
                              ),
                              label: Text(l10n.campaignDiscussionNewMessages),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (_model.accessDenied ||
                    (_model.readOnly && _model.connected))
                  Container(
                    width: double.infinity,
                    color: palette.surface,
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 18,
                          color: palette.muted,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _model.accessDenied
                                ? l10n.campaignDiscussionNoAccess
                                : l10n.campaignDiscussionReadOnly,
                            style: TextStyle(
                              color: palette.muted,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  _composer(palette),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _composer(_ChatPalette palette) {
    final l10n = context.l10n;
    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.line)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _text,
        builder: (context, value, _) {
          final canSend =
              value.text.trim().isNotEmpty &&
              _model.connected &&
              !_model.sending &&
              !_model.readOnly;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: palette.background,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _focus.hasFocus
                          ? palette.accent.withValues(alpha: .3)
                          : palette.line,
                    ),
                  ),
                  child: TextField(
                    controller: _text,
                    focusNode: _focus,
                    enabled: !_model.sending,
                    minLines: 1,
                    maxLines: 5,
                    maxLength: 2000,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: palette.ink,
                    ),
                    onTap: () => setState(() {}),
                    decoration: InputDecoration(
                      hintText: l10n.campaignDiscussionMessageHint,
                      hintStyle: TextStyle(fontSize: 14, color: palette.muted),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 13,
                      ),
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      counterText: value.text.length > 1800
                          ? '${value.text.length}/2000'
                          : '',
                      counterStyle: TextStyle(
                        fontSize: 10,
                        color: palette.muted,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              AnimatedContainer(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  color: canSend || _model.sending
                      ? palette.accent
                      : palette.background,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  tooltip: l10n.campaignDiscussionSend,
                  onPressed: canSend ? _send : null,
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  icon: AnimatedSwitcher(
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : const Duration(milliseconds: 160),
                    child: _model.sending
                        ? const SizedBox(
                            key: ValueKey('sending'),
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            Icons.arrow_upward_rounded,
                            key: const ValueKey('send'),
                            size: 23,
                            color: canSend ? Colors.white : palette.muted,
                          ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ChatPalette {
  _ChatPalette(Brightness brightness) : dark = brightness == Brightness.dark;
  final bool dark;
  Color get background =>
      dark ? const Color(0xFF111B18) : const Color(0xFFF7F8F6);
  Color get surface => dark ? const Color(0xFF17231E) : Colors.white;
  Color get ink => dark ? const Color(0xFFE8EFEA) : const Color(0xFF1B3027);
  Color get muted => dark ? const Color(0xFFA6B8AC) : const Color(0xFF65766C);
  Color get accent => dark ? const Color(0xFF286348) : const Color(0xFF235A43);
  Color get line => dark ? const Color(0xFF2C3A32) : const Color(0xFFE6ECE7);
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.mine,
    required this.grouped,
    required this.palette,
  });
  final CampaignChatMessage message;
  final bool mine;
  final bool grouped;
  final _ChatPalette palette;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final role = message.senderIsCreator
        ? l10n.campaignDiscussionCampaigner
        : l10n.campaignDiscussionVolunteer;
    final name = mine ? l10n.campaignDiscussionYou : message.senderDisplayName;
    final foreground = mine ? Colors.white : palette.ink;
    return LayoutBuilder(
      builder: (context, constraints) => Padding(
        padding: EdgeInsets.only(top: grouped ? 3 : 10, bottom: 3),
        child: Row(
          mainAxisAlignment: mine
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!mine) ...[
              SizedBox(
                width: 28,
                child: grouped
                    ? null
                    : CircleAvatar(
                        radius: 14,
                        backgroundColor: palette.accent.withValues(alpha: .1),
                        foregroundColor: palette.ink,
                        child: Text(
                          message.senderDisplayName.trim().isEmpty
                              ? '?'
                              : message.senderDisplayName
                                    .trim()
                                    .characters
                                    .first
                                    .toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 8),
            ],
            Container(
              constraints: BoxConstraints(
                maxWidth: math.min(
                  540,
                  constraints.maxWidth * .8 - (mine ? 0 : 12),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(14, 11, 14, 9),
              decoration: BoxDecoration(
                color: mine ? palette.accent : palette.surface,
                border: mine ? null : Border.all(color: palette.line),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(mine ? 18 : 5),
                  bottomRight: Radius.circular(mine ? 5 : 18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!grouped) ...[
                    Text(
                      '$name · $role',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: mine
                            ? Colors.white.withValues(alpha: .78)
                            : palette.muted,
                      ),
                    ),
                    const SizedBox(height: 5),
                  ],
                  SelectableText(
                    message.body,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.45,
                      color: foreground,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    widthFactor: 1,
                    child: Text(
                      DateFormat.Hm(
                        context.localeTag,
                      ).format(message.createdAt.toLocal()),
                      style: TextStyle(
                        fontSize: 10,
                        color: mine
                            ? Colors.white.withValues(alpha: .65)
                            : palette.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageEntrance extends StatefulWidget {
  const _MessageEntrance({
    super.key,
    required this.animate,
    required this.child,
  });
  final bool animate;
  final Widget child;
  @override
  State<_MessageEntrance> createState() => _MessageEntranceState();
}

class _MessageEntranceState extends State<_MessageEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 240),
    value: widget.animate ? 0 : 1,
  );
  bool _started = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else if (widget.animate) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    child: widget.child,
    builder: (context, child) {
      final progress = Curves.easeOutCubic.transform(_controller.value);
      return Opacity(
        opacity: progress,
        child: Transform.translate(
          offset: Offset(0, 8 * (1 - progress)),
          child: child,
        ),
      );
    },
  );
}

class _EmptyDiscussion extends StatelessWidget {
  const _EmptyDiscussion({required this.palette, required this.denied});
  final _ChatPalette palette;
  final bool denied;
  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: palette.accent.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(
              denied
                  ? Icons.lock_outline_rounded
                  : Icons.chat_bubble_outline_rounded,
              size: 26,
              color: palette.ink,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            denied
                ? context.l10n.campaignDiscussionNoAccess
                : context.l10n.campaignDiscussionEmpty,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, height: 1.6, color: palette.muted),
          ),
        ],
      ),
    ),
  );
}
