import 'package:flutter/material.dart';

class MetallicButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const MetallicButton({
    Key? key,
    required this.onPressed,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 300.0,
        height: 250.0,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[600]!,
              offset: Offset(0.0, 4.0),
              blurRadius: 8.0,
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey[900]!,
              Colors.grey[900]!,
            ],
          ),
        ),
        child: Center(child: child),
      ),
    );
  }
}
