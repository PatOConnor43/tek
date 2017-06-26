import 'package:tek/models/move.dart';
import 'package:yaml/yaml.dart';

/// Class used to represent a character.
class Character extends Object {
  String _name;
  String get name => _name;

  List _moves;
  List get moves => _moves;

  Character.fromYaml(YamlMap map) {
    _name = map.keys.first;
    _moves = map[_name]['moves']
        .map((move) => new Move.fromYaml(move['move']))
        .toList();
  }

  @override
  String toString() {
    return 'Character(name=$_name, moves=${_moves.length})';
  }
}
