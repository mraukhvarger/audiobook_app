import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:player_book/l10n/generated/app_localizations.dart';

import '../../../library/presentation/providers/library_providers.dart';
import '../../domain/sleep_timer/sleep_timer.dart';
import '../controllers/player_controller.dart';
import '../format_clock.dart';
import '../providers/player_providers.dart';
import '../widgets/playback_settings_sheet.dart';
import '../widgets/sleep_timer_sheet.dart';
import '../widgets/volume_sheet.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key, required this.bookId});

  final String bookId;

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      ref.read(playerControllerProvider(widget.bookId)).flushProgress();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.watch(playerControllerProvider(widget.bookId));

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          ref.invalidate(libraryBookSummariesProvider);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: l10n.back,
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
          ),
          title: Text(controller.book?.title ?? l10n.playerFallback),
          actions: [
            IconButton(
              icon: const Icon(Icons.tune),
              tooltip: l10n.playbackSettingsTitle,
              onPressed: () =>
                  showPlaybackSettingsSheet(context, widget.bookId),
            ),
          ],
        ),
        body: controller.loading
            ? const Center(child: CircularProgressIndicator())
            : controller.book == null
                ? Center(child: Text(l10n.bookNotFound))
                : _PlayerBody(controller: controller),
      ),
    );
  }
}

class _PlayerBody extends StatelessWidget {
  const _PlayerBody({required this.controller});

  final PlayerController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final book = controller.book!;
    final settings = controller.settings;
    final error = controller.error;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _Cover(path: book.coverPath),
          const SizedBox(height: 24),
          Text(
            book.title,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (book.author != null) ...[
            const SizedBox(height: 8),
            Text(book.author!, style: Theme.of(context).textTheme.titleMedium),
          ],
          const SizedBox(height: 8),
          Text(
            l10n.trackOfTotal(
              controller.currentTrackIndex + 1,
              controller.tracks.length,
            ),
          ),
          const SizedBox(height: 24),
          _SeekBar(controller: controller),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ControlButton(
                icon: Icons.replay,
                label: l10n.skipBackSeconds(settings.skipSeconds),
                onPressed: () => controller.skipBy(-settings.skipSeconds),
              ),
              const SizedBox(width: 24),
              IconButton.filled(
                iconSize: 48,
                tooltip: controller.playing ? l10n.pause : l10n.play,
                onPressed: controller.togglePlay,
                icon: Icon(
                  controller.playing ? Icons.pause : Icons.play_arrow,
                ),
              ),
              const SizedBox(width: 24),
              _ControlButton(
                icon: Icons.forward,
                label: l10n.skipForwardSeconds(settings.skipSeconds),
                onPressed: () => controller.skipBy(settings.skipSeconds),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => showPlaybackSettingsSheet(
              context,
              controller.book!.id,
            ),
            icon: const Icon(Icons.speed),
            label: Text(
              l10n.playbackSpeed(settings.speed.toStringAsFixed(2)),
            ),
          ),
          TextButton.icon(
            onPressed: () => showSleepTimerSheet(context, controller.book!.id),
            icon: const Icon(Icons.bedtime_outlined),
            label: Text(_sleepLabel(l10n, controller)),
          ),
          TextButton.icon(
            onPressed: () => showVolumeSheet(context, controller.book!.id),
            icon: const Icon(Icons.volume_up),
            label: Text(_volumeLabel(l10n, controller)),
          ),
          if (controller.sleepTimerPhase == SleepTimerPhase.fading ||
              controller.sleepTimerPhase == SleepTimerPhase.fired)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                l10n.shakeToExtend,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _errorLabel(l10n, error),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ),
          if (error != null && controller.errorDetails != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                controller.errorDetails!,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  String _sleepLabel(AppLocalizations l10n, PlayerController controller) {
    final remaining = controller.sleepTimerRemaining;
    if (controller.sleepTimerActive && remaining != null) {
      return l10n.sleepRemaining(formatClock(remaining));
    }
    return l10n.sleepTimer;
  }

  String _volumeLabel(AppLocalizations l10n, PlayerController controller) {
    final state = controller.volumeState;
    final percent = l10n.percentValue(state.percent.round());
    if (state.hasBoost) {
      return l10n.volumePercentBoost(percent, state.boostDb.round());
    }
    return l10n.volumePercent(percent);
  }

  String _errorLabel(AppLocalizations l10n, PlayerError error) {
    return switch (error) {
      PlayerError.bookNotFound => l10n.bookNotFound,
      PlayerError.startFailed => l10n.playbackStartFailed,
      PlayerError.trackFailed => l10n.playbackTrackFailed,
    };
  }
}

class _SeekBar extends StatefulWidget {
  const _SeekBar({required this.controller});

  final PlayerController controller;

  @override
  State<_SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<_SeekBar> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final duration = controller.durationMs.toDouble();
    final current = (_dragValue ?? controller.positionMs.toDouble())
        .clamp(0.0, duration <= 0 ? 1.0 : duration);

    return Column(
      children: [
        Slider(
          min: 0,
          max: duration <= 0 ? 1 : duration,
          value: duration <= 0 ? 0 : current,
          onChanged: duration <= 0
              ? null
              : (value) => setState(() => _dragValue = value),
          onChangeEnd: duration <= 0
              ? null
              : (value) {
                  setState(() => _dragValue = null);
                  controller.seekToMs(value.toInt());
                },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              formatClock(Duration(milliseconds: current.toInt())),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              formatClock(Duration(milliseconds: controller.durationMs)),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(onPressed: onPressed, icon: Icon(icon)),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    final path = this.path;
    final placeholder = Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Icon(Icons.menu_book, size: 80),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 220,
        height: 220,
        child: path == null
            ? placeholder
            : Image.file(
                File(path),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => placeholder,
              ),
      ),
    );
  }
}
