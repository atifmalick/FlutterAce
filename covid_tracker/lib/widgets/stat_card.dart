import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class StatCard extends StatelessWidget {
  final String title;
  final int value;
  final int? todayValue;
  final Color color;
  final IconData icon;
  final bool isPercentage;

  const StatCard({
    Key? key,
    required this.title,
    required this.value,
    this.todayValue,
    required this.color,
    required this.icon,
    this.isPercentage = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppStyles.cardDecoration.copyWith(
        color: color.withOpacity(0.1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppStyles.subtitleStyle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            isPercentage ? FormatHelper.formatPercentage(value.toDouble())
                : FormatHelper.formatNumber(value),
            style: AppStyles.numberStyle.copyWith(
              fontSize: 28,
              color: color,
            ),
          ),
          if (todayValue != null && todayValue! > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.arrow_upward,
                  color: color,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '+${FormatHelper.formatNumber(todayValue!)} today',
                  style: AppStyles.smallStyle.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: isPercentage ? value / 100 : 0.5,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ],
      ),
    );
  }
}

class AnimatedStatCard extends StatefulWidget {
  final String title;
  final int value;
  final Color color;
  final IconData icon;

  const AnimatedStatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  }) : super(key: key);

  @override
  _AnimatedStatCardState createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<AnimatedStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = IntTween(
      begin: 0,
      end: widget.value,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    )..addListener(() {
      setState(() {});
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StatCard(
      title: widget.title,
      value: _animation.value,
      color: widget.color,
      icon: widget.icon,
    );
  }
}