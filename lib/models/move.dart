import 'dart:developer';
import 'dart:math';

import 'package:yaml/yaml.dart';

enum HitLevel {
  HIGH,
  MID,
  SPECIALMID, // Blocked by b or d/b
  LOW,
}

class Move {
  String _damage;
  String get damage => _damage;

  String _hitLevel;
  String get hitLevel => _hitLevel;

  FuzzyInt _hitFrame;
  FuzzyInt get hitFrame => _hitFrame;

  List<FuzzyInt> _startUpFrame;
  List<FuzzyInt> get startUpFrame => _startUpFrame;

  FuzzyInt _blockFrame;
  FuzzyInt get blockFrame => _blockFrame;

  FuzzyInt _counterFrame;
  FuzzyInt get counterFrame => _counterFrame;

  String _command;
  String get command => _command;

  List<String> _modifiers;
  List<String> get modifiers => _modifiers;

  static final _hitFrameRegex = new RegExp(r'([+|-]\d+)|0');

  /// Used to remove:
  ///   - Things surrounded by parenthesis: (ROL)
  ///   - Any stray letters from modifiers: CS
  ///   - Any questionable things: JG?
  ///   - Any lonely '~' or '~' with attached whitespace: ~
  static final _startUpFrameRegex = new RegExp(r'\(.*\)|[A-Z|a-z|\?]|~\s?');

  static final _commaEmptyRegex = new RegExp(r'(,\s{2,})');

  Move.fromYaml(YamlMap map) {
    _damage = map['damage'];
    _hitLevel = map['hit_level'];
    _hitFrame = _parseHitFrame(map['hit_frame']);
    _startUpFrame = _parseStartUpFrame(map['start_up_frames']);
    _blockFrame = _parseBlockFrame(map['block_frame']);
    _counterFrame = _parseCounterFrame(map['counter_hit_frame']);
    _command = map['command'];
    // Modifiers should be populated as a side-effect.
  }

  FuzzyInt _parseHitFrame(String hitFrame) {
    final frameSet = _hitFrameRegex
        .allMatches(hitFrame)
        .map((Match m) => int.parse(m.group(0)))
        .toSet();

    return new FuzzyInt(frameSet);
  }

  List<FuzzyInt> _parseStartUpFrame(String startUpFrame) {
    var parsed = startUpFrame.replaceAll(_startUpFrameRegex, '');
    if (parsed.isEmpty) return [];
    return parsed
        .split(',')
        .where((String s) => s.trim().isNotEmpty)
        .map((String s) => new FuzzyInt.fromString(s.trim()))
        .toList();
  }

  FuzzyInt _parseBlockFrame(String blockFrame) {
    if (blockFrame == '\u2013') print(blockFrame);
    final frameSet = _hitFrameRegex
        .allMatches(blockFrame)
        .map((Match m) => int.parse(m.group(0)))
        .toSet();
    if (blockFrame == '\u2013') print(frameSet);
    return new FuzzyInt(frameSet);
  }

  FuzzyInt _parseCounterFrame(String counterFrame) {
    final frameSet = _hitFrameRegex
        .allMatches(counterFrame)
        .map((Match m) => int.parse(m.group(0)))
        .toSet();
    return new FuzzyInt(frameSet);
  }

  List<String> _parseCommand(arg0) {
    return null;
  }

  @override
  String toString() {
    return 'Move{_damage: $_damage, _hitLevel: $_hitLevel, _hitFrame: $_hitFrame, _startUpFrame: $_startUpFrame, _blockFrame: $_blockFrame, _counterFrame: $_counterFrame, _command: $_command, _modifiers: $_modifiers}';
  }
}

class FuzzyInt {
  Set<int> _values;
  Set<int> get values => _values;

  FuzzyInt(this._values);

  FuzzyInt.fromString(String fuzzyString) {
    _values = new Set();
    if (fuzzyString.isEmpty) return;
    // Ignore anything after the first space or '('
    final cutSpace = fuzzyString.split(new RegExp(r'[\s\(]')).first;
    final tildeDelimited = cutSpace.split('~');
    try {
      tildeDelimited.forEach((String s) => _values.add(int.parse(s)));
    } catch (e, stacktrace) {
      print(stacktrace);
      print('Current state of _values: $_values');
      print('Trying to parse: $tildeDelimited');
    }
  }

  @override
  String toString() {
    return 'FuzzyInt{_values: $_values}';
  }

  operator >(dynamic other) => other is int
      ? _compareIntGreaterThan(other)
      : other is FuzzyInt
          ? _compareFuzzyIntGreaterThan(other)
          : throw new StateError("Wrong type");

  operator <(dynamic other) => other is int
      ? _compareIntLessThan(other)
      : other is FuzzyInt
          ? _compareFuzzyIntLessThan(other)
          : throw new StateError("Wrong type");

  bool _compareIntGreaterThan(int other) =>
      _values.where((int v) => v > other).toList().isNotEmpty;

  bool _compareFuzzyIntGreaterThan(FuzzyInt other) =>
      _compareIntGreaterThan(other._values.reduce(max));

  bool _compareIntLessThan(int other) =>
      _values.where((int v) => v < other).toList().isNotEmpty;

  bool _compareFuzzyIntLessThan(FuzzyInt other) =>
      _compareIntLessThan(other._values.reduce(min));
}
