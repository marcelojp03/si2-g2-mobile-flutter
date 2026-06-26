import 'package:flutter/material.dart';
import 'glass_card.dart';

class AppDialog {
  static Future<T?> show<T>(BuildContext context, {
    required Widget child,
    double? maxHeight,
    bool dismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AppDialogWrapper(
        maxHeight: maxHeight,
        child: child,
      ),
    );
  }
}

class _AppDialogWrapper extends StatelessWidget {
  final Widget child;
  final double? maxHeight;

  const _AppDialogWrapper({required this.child, this.maxHeight});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: GlassCard(
        margin: const EdgeInsets.fromLTRB(12, 20, 12, 12),
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: maxHeight ?? 480),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
