import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
                  'Таймер сна',
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
                'Осталось ${formatClock(remaining)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            const SizedBox(height: 16),
            Text(
              'Длительность',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final preset in SleepTimerSettings.presets)
                  ChoiceChip(
                    label: Text('$preset мин'),
                    selected: settings.durationMinutes == preset,
                    onSelected: (_) => controller.updateSleepSettings(
                      settings.copyWith(durationMinutes: preset),
                    ),
                  ),
                ActionChip(
                  avatar: const Icon(Icons.edit, size: 18),
                  label: Text('${settings.durationMinutes} мин…'),
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
              title: const Text('Реакция на встряхивание'),
              value: settings.shakeEnabled,
              onChanged: (value) => controller.updateSleepSettings(
                settings.copyWith(shakeEnabled: value),
              ),
            ),
            if (settings.shakeEnabled) ...[
              const SizedBox(height: 8),
              Text(
                'Чувствительность',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _SensitivityChip(
                    label: 'Низкая',
                    threshold: SleepTimerSettings.lowSensitivityThreshold,
                    current: settings.shakeThreshold,
                    onSelected: (threshold) => controller.updateSleepSettings(
                      settings.copyWith(shakeThreshold: threshold),
                    ),
                  ),
                  _SensitivityChip(
                    label: 'Средняя',
                    threshold: SleepTimerSettings.mediumSensitivityThreshold,
                    current: settings.shakeThreshold,
                    onSelected: (threshold) => controller.updateSleepSettings(
                      settings.copyWith(shakeThreshold: threshold),
                    ),
                  ),
                  _SensitivityChip(
                    label: 'Высокая',
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
                label: const Text('Симулировать встряхивание (debug)'),
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
    final input = TextEditingController(
      text: settings.durationMinutes.toString(),
    );
    final result = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Длительность таймера'),
        content: TextField(
          controller: input,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            suffixText: 'мин',
            helperText: 'От 1 до 480 минут',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              final minutes = int.tryParse(input.text.trim());
              Navigator.of(dialogContext).pop(minutes);
            },
            child: const Text('Сохранить'),
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
