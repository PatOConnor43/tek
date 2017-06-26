import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'package:tek/models/character.dart';
import 'package:tek/models/character_fetcher.dart';
import 'package:tek/models/move.dart';
import 'package:tek/widgets/charcter_select_widgets/names_dropdown.dart';

class CharacterSelectWidget extends StatefulWidget {
  CharacterSelectWidget(
      {Key key,
      @required this.fetcher,
      this.selectedMoveController,
      this.selectedMoveStream})
      : super(key: key);

  final Fetcher fetcher;
  final StreamController<Move> selectedMoveController;
  final Stream<Move> selectedMoveStream;

  @override
  _CharacterSelectState createState() => new _CharacterSelectState();
}

class _CharacterSelectState extends State<CharacterSelectWidget> {
  /// Store the name of the selected character to get it from the fetcher.
  String _characterName;

  /// The future that will be completed with the result of the character fetcher.
  Future<Character> _rightCharacter;

  /// The filter that will be used to display the second character's moves.
  FuzzyInt _moveFilter;

  /// A reference to the [widget.selectedMoveStream] listener so that we can clean up responsibly.
  StreamSubscription _moveStreamSubscription;

  _CharacterSelectState();

  @override
  void initState() {
    super.initState();
    _moveStreamSubscription =
        widget?.selectedMoveStream?.listen(_handleSelectedMoveChange);
  }

  _handleSelectedMoveChange(Move move) => setState(() {
        _moveFilter = move.blockFrame;
      });

  @override
  void didUpdateWidget(CharacterSelectWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _moveStreamSubscription?.cancel();
    _moveStreamSubscription =
        widget?.selectedMoveStream?.listen(_handleSelectedMoveChange);
  }

  @override
  void dispose() {
    _moveStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new ListView(
      children: <Widget>[
        new Flex(
          direction: Axis.horizontal,
          children: <Widget>[
            new Flexible(
              flex: 1,
              child: new NamesDropdownWidget(
                value: _characterName,
                hint: 'Character',
                onChange: (value) => setState(() {
                      _characterName = value;
                      _rightCharacter =
                          widget.fetcher.getCharacterByName(value);
                    }),
              ),
            ),
          ],
        ),
        new FutureBuilder(
          future: _rightCharacter,
          builder: ((BuildContext context, AsyncSnapshot<Character> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return new Flex(
                  direction: Axis.horizontal,
                  children: <Widget>[
                    new Flexible(
                      child: new Column(
                        children: _getListViewCards(snapshot.data).toList(),
                      ),
                    ),
                  ],
                );
              default:
                return new Container();
            }
          }),
        ),
      ],
    );
  }

  Iterable _getListViewCards(Character character) {
    return character.moves.where(_moveIsPunishable).map((Move m) {
      return new InkWell(
        child: new Card(
          child: new Column(
            children: <Widget>[
              new Container(
                constraints: new BoxConstraints.tightForFinite(width: 500.0),
                child: new ListTile(
                  title: new Text(m.command),
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          widget?.selectedMoveController?.add(m);
          print(m);
        },
      );
    });
  }

  bool _moveIsPunishable(Move move) {
    // Set arbitrarily large default if a filter wasn't selected
    final filter = _moveFilter ?? new FuzzyInt(new Set.from([1000]));
    if (move.startUpFrame.isEmpty || filter.values.isEmpty) return false;
    return move.startUpFrame.first < filter.values.reduce(min).abs();
  }
}
