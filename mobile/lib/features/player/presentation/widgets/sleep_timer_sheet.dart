import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:player_book/l10n/generated/app_localizations.dart';

import '../../domain/sleep_timer/sleep_timer_settings.dart';
import '../controllers/player_controller.dart';
import '../format_clock.dart';
import '../providers/player_providers.dart';

Future<void> showSleepTimerSheet(BuildContext context, String bookId) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => SleepTimerSheet(bookId: bookId),
  );
}

class SleepTimerSheet extends ConsumerWidget {
  const SleepTimerSheet({super.key, required this.bookId});

  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.watch(playerControllerProvider(bookId));
    final settings = controller.sleepSettings;
    final remaining = controller.sleepTimerRemaining;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bedtime_outlined),
                const SizedBox(width: 8),
                Text(
                  l10n.sleepTimer,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Switch(
                  value: controller.sleepTimerActive,
                  onChanged: (_) => controller.toggleSleepTimer(),
                ),
              ],
            ),
            if (remaining != null)
              Text(
                l10n.sleepRemainingLeft(formatClock(remaining)),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            const SizedBox(height: 16),
            Text(
              l10n.durationLabel,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final preset in SleepTimerSettings.presets)
                  ChoiceChip(
                    label: Text(l10n.durationMinutes(preset)),
                    selected: settings.durationMinutes == preset,
                    onSelected: (_) => controller.updateSleepSettings(
                      settings.copyWith(durationMinutes: preset),
                    ),
                  ),
                ActionChip(
                  avatar: const Icon(Icons.edit, size: 18),
                  label: Text(
                    l10n.durationMinutesEllipsis(settings.durationMinutes),
                  ),
                  onPressed: () => _askCustomMinutes(
                    context,
                    controller,
                    settings,
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.shakeReaction),
              value: settings.shakeEnabled,
              onChanged: (value) => controller.updateSleepSettings(
                settings.copyWith(shakeEnabled: value),
              ),
            ),
            if (settings.shakeEnabled) ...[
              const SizedBox(height: 8),
              Text(
                l10n.sensitivity,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _SensitivityChip(
                    label: l10n.sensitivityLow,
                    threshold: SleepTimerSettings.lowSensitivityThreshold,
                    current: settings.shakeThreshold,
                    onSelected: (threshold) => controller.updateSleepSettings(
                      settings.copyWith(shakeThreshold: threshold),
                    ),
                  ),
                  _SensitivityChip(
                    label: l10n.sensitivityMedium,
                    threshold: SleepTimerSettings.mediumSensitivityThreshold,
                    current: settings.shakeThreshold,
                    onSelected: (threshold) => controller.updateSleepSettings(
                      settings.copyWith(shakeThreshold: threshold),
                    ),
                  ),
                  _SensitivityChip(
                    label: l10n.sensitivityHigh,
                    threshold: SleepTimerSettings.highSensitivityThreshold,
                    current: settings.shakeThreshold,
                    onSelected: (threshold) => controller.updateSleepSettings(
                      settings.copyWith(shakeThreshold: threshold),
                    ),
                  ),
                ],
              ),
            ],
            if (kDebugMode) ...[
              const Divider(height: 32),
              OutlinedButton.icon(
                onPressed: controller.simulateShake,
                icon: const Icon(Icons.vibration),
                label: Text(l10n.simulateShakeDebug),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _askCustomMinutes(
    BuildContext context,
    PlayerController controller,
    SleepTimerSettings settings,
  ) async {
    final l10n = AppLocalizations.of(context);
    final input = TextEditingController(
      text: settings.durationMinutes.toString(),
    );
    final result = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.timerDurationTitle),
        content: TextField(
          controller: input,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            suffixText: l10n.minutesSuffix,
            helperText: l10n.sleepTimerRange,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final minutes = int.tryParse(input.text.trim());
              Navigator.of(dialogContext).pop(minutes);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    if (result == null) return;
    final clamped = result.clamp(
      SleepTimerSettings.minMinutes,
      SleepTimerSettings.maxMinutes,
    );
    await controller.updateSleepSettings(
      settings.copyWith(durationMinutes: clamped),
    );
  }
}

class _SensitivityChip extends StatelessWidget {
  const _SensitivityChip({
    required this.label,
    required this.threshold,
    required this.current,
    required this.onSelected,
  });

  final String label;
  final double threshold;
  final double current;
  final ValueChanged<double> onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: (current - threshold).abs() < 0.01,
      onSelected: (_) => onSelected(threshold),
    );
  }
}
