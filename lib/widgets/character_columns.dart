import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tek/constants.dart';
import 'package:tek/models/character_fetcher.dart';
import 'package:tek/widgets/character_select.dart';

class CharacterColumnsWidget extends StatefulWidget {
  @override
  State createState() => new _CharacterColumnsState();
}

class _CharacterColumnsState extends State<CharacterColumnsWidget> {
  /// Class used to access [Character]s
  Fetcher _fetcher;

  /// Controller used to communicate which move was selected.
  ///
  /// The [CharacterSelectWidget] that receives the controller is responsible
  /// for delegating the selected move to the [CharacterSelectWidget] that
  /// receives the [controller.stream]
  StreamController controller;

  @override
  void initState() {
    _fetcher = new YamlFetcher();
    controller = new StreamController.broadcast();
    // Populate all characters in cache to speed up selection.
    CHARACTER_NAMES.forEach((String name) => _fetcher.getCharacterByName(name));
    super.initState();
  }

  @override
  void dispose() {
    controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text('Tek')),
      body: new GridView.count(
        scrollDirection: Axis.vertical,
        childAspectRatio: 0.3,
        padding: const EdgeInsets.all(4.0),
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        crossAxisCount: 2,
        children: <Widget>[
          new CharacterSelectWidget(
              fetcher: _fetcher, selectedMoveController: controller),
          new CharacterSelectWidget(
              fetcher: _fetcher, selectedMoveStream: controller.stream),
        ],
      ),
    );
  }
}
