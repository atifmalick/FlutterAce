import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedTechChip extends StatefulWidget {
  final String label;
  final IconData? icon;

  const AnimatedTechChip({
    super.key,
    required this.label,
    this.icon,
  });

  @override
  State<AnimatedTechChip> createState() => _AnimatedTechChipState();
}

class _AnimatedTechChipState extends State<AnimatedTechChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _isHovered 
              ? theme.colorScheme.primary.withOpacity(0.2) 
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered 
                ? theme.colorScheme.primary.withOpacity(0.5) 
                : Colors.white.withOpacity(0.05),
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                size: 14,
                color: _isHovered ? theme.colorScheme.primary : theme.textTheme.bodyMedium?.color,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              widget.label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: _isHovered ? theme.colorScheme.primary : theme.textTheme.bodyMedium?.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ).animate(target: _isHovered ? 1 : 0).scaleXY(end: 1.05, duration: 200.ms),
    );
  }
}
