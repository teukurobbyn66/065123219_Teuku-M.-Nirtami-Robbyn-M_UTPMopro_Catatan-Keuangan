import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  const EmptyState({super.key, required this.icon, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Gap.xxl, horizontal: Gap.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: context.palette.secondary),
          const SizedBox(height: Gap.m),
          Text(title, style: AppText.bodyStrong(context), textAlign: TextAlign.center),
          const SizedBox(height: Gap.xs),
          Text(message, style: AppText.caption(context), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
