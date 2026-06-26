import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FadeSlideTransition extends CustomTransitionPage<void> {
  FadeSlideTransition({required LocalKey super.key, required super.child})
      : super(
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          transitionsBuilder: (_, anim, __, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.15, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: anim,
                curve: Curves.easeOutCubic,
                reverseCurve: Curves.easeInCubic,
              )),
              child: FadeTransition(
                opacity: anim,
                child: child,
              ),
            );
          },
        );
}

CustomTransitionPage<void> buildPageTransition(LocalKey key, Widget child) {
  return FadeSlideTransition(key: key, child: child);
}
