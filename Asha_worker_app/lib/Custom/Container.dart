import 'package:flutter/material.dart';

class MyContainer extends StatefulWidget {
  final double height;
  final Color color;
  final double? width;
  final child;
  final double pad;
  const MyContainer(    {super.key, required this.height, required this.color,  this.width, this.child, required this.pad});

  @override
  State<MyContainer> createState() => _MyContainerState();
}

class _MyContainerState extends State<MyContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      padding: EdgeInsets.all(widget.pad),
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(10),

        boxShadow: [BoxShadow(
          color: Colors.grey,
          offset: Offset(2,3),

        )]
      ),
      child: widget.child,
    );
  }
}
