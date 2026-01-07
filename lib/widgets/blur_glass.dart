import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Widget? child;
  final Color color;
  final double blur;
  final EdgeInsetsGeometry padding;

  const GlassContainer({
    Key? key,
    this.width = double.infinity,
    this.height = double.infinity,
    this.borderRadius = 20,
    this.child,
    this.color = Colors.white,
    this.blur = 15,
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2), // frosty tint
            borderRadius: BorderRadius.circular(borderRadius),
            // border: Border.all(
            //   color: Colors.white.withOpacity(0.3), // glowing border
            //   width: 1.5,
            // ),
          ),
          child: child,
        ),
      ),
    );
  }
}
