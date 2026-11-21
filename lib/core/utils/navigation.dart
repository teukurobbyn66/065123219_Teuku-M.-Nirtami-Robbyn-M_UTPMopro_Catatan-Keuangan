import 'package:flutter/material.dart';

/// Transisi halaman: fade + geser halus.
Future<T?> pushPage<T>(BuildContext context, Widget page) {
  return Navigator.of(context).push<T>(PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, anim, __, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.04), end: Offset.zero).animate(curved),
          child: child,
        ),
      );
    },
  ));
}
