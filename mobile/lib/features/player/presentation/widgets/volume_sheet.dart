import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:player_book/l10n/generated/app_localizations.dart';

import '../../domain/volume/volume_state.dart';
import '../providers/player_providers.dart';

Future<void> showVolumeSheet(BuildContext context, String bookId) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => VolumeSheet(bookId: bookId),
  );
}

class VolumeSheet extends ConsumerWidget {
  const VolumeSheet({super.key, required this.bookId});

  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.watch(playerControllerProvider(bookId));
    final state = controller.volumeState;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.volume, style: Theme.of(context).textTheme.titleMedium),
            Row(
              children: [
                const Icon(Icons.volume_down),
                Expanded(
                  child: Slider(
                    min: VolumeState.minVolume,
                    max: VolumeState.maxVolume,
                    divisions:
                        ((VolumeState.maxVolume - VolumeState.minVolume) /
                                VolumeState.volumeStep)
                            .round(),
                    value: state.volume,
                    label: l10n.percentValue(state.percent.round()),
                    onChanged: controller.setVolume,
                  ),
                ),
                const Icon(Icons.volume_up),
                const SizedBox(width: 8),
                SizedBox(
                  width: 48,
                  child: Text(
                    l10n.percentValue(state.percent.round()),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Text(
              l10n.volumeBoost,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    min: VolumeState.minBoostDb,
                    max: VolumeState.maxBoostDb,
                    divisions:
                        ((VolumeState.maxBoostDb - VolumeState.minBoostDb) /
                                VolumeState.boostStepDb)
                            .round(),
                    value: state.boostDb,
                    label: state.hasBoost
                        ? l10n.boostDb(state.boostDb.round())
                        : l10n.boostOff,
                    onChanged: (value) =>
                        controller.setBoost(value.roundToDouble()),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 64,
                  child: Text(
                    state.hasBoost
                        ? l10n.boostDb(state.boostDb.round())
                        : l10n.boostOffShort,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            if (state.hasBoost)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  l10n.boostWarning,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: controller.resetVolume,
              icon: const Icon(Icons.restart_alt),
              label: Text(l10n.resetVolumeBoost),
            ),
          ],
        ),
      ),
    );
  }
}
