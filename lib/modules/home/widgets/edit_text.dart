import 'package:flutter/material.dart';
import 'package:flutter_nop/nop_state.dart';
import 'package:nop/utils.dart';

import '../../text_style/text_style.dart';

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
    final ts = context.getType<TextStyleConfig>().data;
    return EditableText(
      controller: controller,
      backgroundCursorColor: Colors.grey,
      cursorColor: Colors.cyan,
      focusNode: forceNode,
      style: ts.body1,
    );
  }
}
