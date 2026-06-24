import 'package:flutter/material.dart';

class CommonSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color activeColor;
  final Color inactiveColor;

  const CommonSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor = Colors.green,
    this.inactiveColor = Colors.red,
  });

  @override
  State<CommonSwitch> createState() => _CommonSwitchState();
}

class _CommonSwitchState extends State<CommonSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.9,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onChanged != null) {
      _controller.reverse();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onChanged != null) {
      _controller.forward();
      widget.onChanged!(!widget.value);
    }
  }

  void _handleTapCancel() {
    if (widget.onChanged != null) {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _controller,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          width: 54,
          height: 28,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: widget.value
                ? widget.activeColor.withValues(alpha: 0.25)
                : widget.inactiveColor.withValues(alpha: 0.25),
            border: Border.all(
              color: widget.value
                  ? widget.activeColor.withValues(alpha: 0.5)
                  : widget.inactiveColor.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              if (widget.value)
                BoxShadow(
                  color: widget.activeColor.withValues(alpha: 0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              if (!widget.value)
                BoxShadow(
                  color: widget.inactiveColor.withValues(alpha: 0.1),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: widget.value
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.value ? widget.activeColor : widget.inactiveColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 3,
                    offset: const Offset(0, 1.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
