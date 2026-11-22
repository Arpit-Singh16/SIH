import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyCheckbox extends StatefulWidget {
  final String text;
   final bool is_selected;
   final onChanged;
  const MyCheckbox( {super.key, required this.text,   required this.is_selected, this.onChanged});

  @override
  State<MyCheckbox> createState() => _CheckboxState();
}

class _CheckboxState extends State<MyCheckbox> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: widget.is_selected,
          onChanged: (value) {
            widget.onChanged(value!); // Pass value back to parent
          },
        ),
        Text(widget.text),
      ],
    );
  }
}
