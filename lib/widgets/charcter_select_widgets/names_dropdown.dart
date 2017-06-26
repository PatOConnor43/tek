import 'package:flutter/material.dart';
import 'package:tek/constants.dart';

class NamesDropdownWidget extends StatelessWidget {
  final String value;
  final String hint;
  final ValueChanged<String> onChange;

  NamesDropdownWidget({Key key, this.value, this.hint, this.onChange})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Flex(
      direction: Axis.vertical,
      children: [
        new DropdownButton(
            value: value,
            hint: new Text(hint),
            onChanged: (value) => onChange(value),
            items: _getCharacterNames().toList()),
      ],
    );
  }

  Iterable<DropdownMenuItem<String>> _getCharacterNames() sync* {
    for (String name in CHARACTER_NAMES) {
      yield new DropdownMenuItem(
          key: new Key(name), value: name, child: new Text(name));
    }
  }
}
