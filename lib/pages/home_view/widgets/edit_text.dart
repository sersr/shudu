import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/provider.dart';

class EditText extends StatefulWidget {
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
      print('forc Node');
    });
  }

  @override
  Widget build(BuildContext context) {
    final ts = Provider.of<TextStyleConfig>(context);
    Draggable;
    return Container(
      child: EditableText(
        controller: controller,
        backgroundCursorColor: Colors.grey,
        cursorColor: Colors.cyan,
        focusNode: forceNode,
        style: ts.body1,
      ),
    );
  }
}
