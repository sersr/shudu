import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utils/utils.dart';

import '../../../provider/provider.dart';

class EditText extends StatefulWidget {
  const EditText({Key? key}) : super(key: key);

  @override
  _EditTextState createState() => _EditTextState();
}

class _EditTextState extends State<EditText> {
  final controller = TextEditingController(text: '22');
  final forceNode = FocusNode();

  @override
  void initState() {
    super.initState();
    forceNode.addListener(() {
      Log.i('forc Node');
    });
  }

  @override
  Widget build(BuildContext context) {
    final ts = context.read<TextStyleConfig>();
    Draggable;
    return EditableText(
      controller: controller,
      backgroundCursorColor: Colors.grey,
      cursorColor: Colors.cyan,
      focusNode: forceNode,
      style: ts.body1,
    );
  }
}
