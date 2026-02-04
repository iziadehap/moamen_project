import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class DashboardButton extends StatefulWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const DashboardButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  State<DashboardButton> createState() => _DashboardButtonState();
}

class _DashboardButtonState extends State<DashboardButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(25),
            boxShadow: AppColors.glowShadow,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (widget.color ?? Theme.of(context).primaryColor)
                      .withOpacity(0.1),
                ),
                child: Icon(
                  widget.icon,
                  size: 40,
                  color: widget.color ?? Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
