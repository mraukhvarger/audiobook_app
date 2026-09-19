import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/settings/playback_settings.dart';
import '../providers/player_providers.dart';

Future<void> showPlaybackSettingsSheet(
  BuildContext context,
  String bookId,
) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => PlaybackSettingsSheet(bookId: bookId),
  );
}

class PlaybackSettingsSheet extends ConsumerWidget {
  const PlaybackSettingsSheet({super.key, required this.bookId});

  static const List<double> speedPresets = [
    0.75,
    1.0,
    1.25,
    1.5,
    1.75,
    2.0,
    2.5,
    3.0,
  ];
  static const List<int> skipPresets = [10, 15, 30, 45, 60];
  static const List<int> rewindPresets = [5, 10, 15, 20, 30];

  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(playerControllerProvider(bookId));
    final settings = controller.settings;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Скорость', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final preset in speedPresets)
                  ChoiceChip(
                    label: Text('${preset}x'),
                    selected: (settings.speed - preset).abs() < 0.001,
                    onSelected: (_) => controller.setSpeed(preset),
                  ),
              ],
            ),
            Slider(
              min: PlaybackSettings.minSpeed,
              max: PlaybackSettings.maxSpeed,
              divisions:
                  ((PlaybackSettings.maxSpeed - PlaybackSettings.minSpeed) /
                          PlaybackSettings.speedStep)
                      .round(),
              value: settings.speed,
              label: settings.speed.toStringAsFixed(2),
              onChanged: controller.setSpeed,
            ),
            const Divider(),
            Text(
              'Интервал перемотки',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final seconds in skipPresets)
                  ChoiceChip(
                    label: Text('$seconds с'),
                    selected: settings.skipSeconds == seconds,
                    onSelected: (_) => controller.updateSettings(
                      settings.copyWith(skipSeconds: seconds),
                    ),
                  ),
              ],
            ),
            const Divider(),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Автоотмотка при возобновлении'),
              value: settings.autoRewindEnabled,
              onChanged: (value) => controller.updateSettings(
                settings.copyWith(autoRewindEnabled: value),
              ),
            ),
            if (settings.autoRewindEnabled) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final seconds in rewindPresets)
                    ChoiceChip(
                      label: Text('$seconds с'),
                      selected: settings.autoRewindSeconds == seconds,
                      onSelected: (_) => controller.updateSettings(
                        settings.copyWith(autoRewindSeconds: seconds),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
