import 'package:flutter/material.dart';

class CommonContainer extends StatelessWidget {
  const CommonContainer({
    super.key,
    this.height,
    this.width,
    this.child,
    this.padding,
    this.margin,
    this.alignment,
    this.border,
    this.boxShadow,
    this.borderRadius,
    this.gradient,
  });

  final double? height;
  final double? width;
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final AlignmentGeometry? alignment;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final BorderRadiusGeometry? borderRadius;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: padding,
      margin: margin,
      alignment: alignment,
      decoration: BoxDecoration(
        gradient: gradient ??
            const LinearGradient(
              colors: [
                Color(0xffebffff),
                Colors.white,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
        borderRadius: borderRadius ?? BorderRadius.circular(10),
        border: border,
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: Colors.blueGrey.withValues(alpha: 0.5),
                spreadRadius: 1,
                blurRadius: 1,
                offset: const Offset(.2, .2),
              ),
            ],
      ),
      child: child,
    );
  }
}
