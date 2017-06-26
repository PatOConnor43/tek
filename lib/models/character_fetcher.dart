import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:yaml/yaml.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:tek/models/character.dart';

/// Class used to fetch characters from some datasource. Possible implementations
/// could be:
///   - file (YAML)
///   - service
///   - sqlite
abstract class Fetcher {
  Future<Character> getCharacterByName(String name);
}

class YamlFetcher implements Fetcher {
  Map<String, Character> _characterCache;

  YamlFetcher() : _characterCache = {};

  @override
  Future<Character> getCharacterByName(String name) async {
    if (_characterCache.containsKey(name)) {
      return _characterCache[name];
    }
    String content =
        await rootBundle.loadString('assets/$name.yaml', cache: true);
    final doc = loadYaml(content);
    Character newCharacter = new Character.fromYaml(doc);
    print(newCharacter);
    _characterCache[name] = newCharacter;
    return newCharacter;
  }
}
