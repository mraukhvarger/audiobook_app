import 'package:flutter_test/flutter_test.dart';
import 'package:player_book/features/player/domain/volume/volume_state.dart';

void main() {
  test('defaults to full volume without boost', () {
    const state = VolumeState();
    expect(state.volume, 1.0);
    expect(state.boostDb, 0);
    expect(state.hasBoost, isFalse);
    expect(state.percent, 100);
  });

  test('copyWith updates individual fields', () {
    const state = VolumeState();
    expect(state.copyWith(volume: 0.5).volume, 0.5);
    expect(state.copyWith(boostDb: 8).boostDb, 8);
  });

  test('hasBoost is true for positive gain only', () {
    expect(const VolumeState(boostDb: 0).hasBoost, isFalse);
    expect(const VolumeState(boostDb: 1).hasBoost, isTrue);
  });

  test('equality is value based', () {
    expect(
      const VolumeState(volume: 0.5, boostDb: 4),
      const VolumeState(volume: 0.5, boostDb: 4),
    );
    expect(
      const VolumeState(volume: 0.5),
      isNot(const VolumeState(volume: 0.6)),
    );
  });

  test('boost maximum is 20 dB', () {
    expect(VolumeState.maxBoostDb, 20);
    expect(VolumeState.volumeStep, 0.01);
  });
}
