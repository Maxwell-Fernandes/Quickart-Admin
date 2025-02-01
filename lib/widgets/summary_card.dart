import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final Widget value;
  final IconData icon;
  final Color? color;

  const SummaryCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Icon(
                icon,
                color: color ?? Theme.of(context).primaryColor,
              ),
            ],
          ),
          const SizedBox(height: 16),
          value,
        ],
      ),
    );
  }
}
