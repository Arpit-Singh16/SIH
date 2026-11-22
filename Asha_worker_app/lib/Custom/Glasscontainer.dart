import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

class GlassCardExample extends StatefulWidget {
  final Widget child;
  const GlassCardExample({super.key, required this.child});

  @override
  State<GlassCardExample> createState() => _GlassCardExampleState();
}

class _GlassCardExampleState extends State<GlassCardExample> {
  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      width: 300,
      height: 180,
      borderRadius: 20,
      blur: 15,
      alignment: Alignment.center,
      border: 2,
      linearGradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.2),
          Colors.white.withOpacity(0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderGradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.5),
          Colors.white.withOpacity(0.1),
        ],
      ),
      child: widget.child, // ✅ works in Stateful
    );
  }
}
