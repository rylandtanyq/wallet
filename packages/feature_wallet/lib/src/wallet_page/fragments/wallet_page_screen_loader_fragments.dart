import 'package:flutter/material.dart';

class FullscreenLoader {
  OverlayEntry? _entry;

  void show(BuildContext context, {required String message}) {
    if (_entry != null) return;

    _entry = OverlayEntry(
      builder: (ctx) => Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            ModalBarrier(dismissible: false, color: Theme.of(ctx).colorScheme.scrim.withOpacity(0.5)),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(color: Theme.of(ctx).colorScheme.surface.withOpacity(0.9), borderRadius: BorderRadius.circular(14)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 3, color: Theme.of(ctx).colorScheme.primary)),
                    const SizedBox(height: 12),
                    Text(
                      message,
                      style: Theme.of(
                        ctx,
                      ).textTheme.bodyMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(ctx).colorScheme.onBackground),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context, rootOverlay: true).insert(_entry!);
  }

  void hide() {
    _entry?.remove();
    _entry = null;
  }

  bool get isShowing => _entry != null;
}
