  import 'package:flutter/material.dart';

  class Textfieldcust extends StatefulWidget {
    final String text;
    final TextEditingController controller;
    final TextInputType? type;
    final bool? readonly;
    final IconData? icon;
    final bool? secure;
   const Textfieldcust({super.key, required this.controller, required this.text, required this.icon, this.type, this.readonly, this.secure});

    @override
    State<Textfieldcust> createState() => _TextfieldcustState();
  }

  class _TextfieldcustState extends State<Textfieldcust> {
    @override
    Widget build(BuildContext context) {
      return Container(
        height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        // border: Border.all(
        //   color: Colors.black26,
        //   width: 2,
        // ),
      ),
        child: TextField(
          controller: widget.controller,
          keyboardType: widget.type,
          readOnly: widget.readonly??false,
          obscureText: widget.secure?? false,
          decoration: InputDecoration(
            labelText: widget.text,
            prefixIcon: Icon(widget.icon),
            border: OutlineInputBorder(), // ✅ Removes default underline
            contentPadding: EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      );
    }
  }
