import 'package:flutter/material.dart';
import 'intro_theme.dart';

/// Thumbs button with local visual state.
/// If [onTap] is supplied, it will be called and the local selected state toggles.
class ThumbButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const ThumbButton({super.key, required this.icon, this.onTap});

  @override
  State<ThumbButton> createState() => _ThumbButtonState();
}

class _ThumbButtonState extends State<ThumbButton> {
  bool _isSelected = false;

  void _handleTap() {
    widget.onTap?.call();
    setState(() => _isSelected = !_isSelected);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _handleTap,
      child: Container(
        height: 50,
        width: 150,
        decoration: BoxDecoration(
          color: _isSelected ? IntroTheme.blue : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: IntroTheme.blue, width: 1),
        ),
        child: Center(
          child: Icon(
            widget.icon,
            color: _isSelected ? Colors.white : IntroTheme.blue,
          ),
        ),
      ),
    );
  }
}
