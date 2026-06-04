import 'dart:async';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  Snackbar Type Enum
// ─────────────────────────────────────────────
enum SnackbarType { success, info, error, warning }

// ─────────────────────────────────────────────
//  CustomSnackbar — tanpa context, panggil dari mana saja
//
//  Setup (sekali saja, biasanya di main.dart):
//    CustomSnackbar.init(navKey);   // pakai navKey yang sudah ada
// ─────────────────────────────────────────────
class CustomSnackbar {
  // Key yang di-inject dari luar (pakai navKey yang sudah ada di project)
  static GlobalKey<NavigatorState>? _navKey;

  /// Panggil sekali di main() atau sebelum MaterialApp build.
  /// Cukup passing navKey yang sudah kamu pakai di MaterialApp.
  static void init(GlobalKey<NavigatorState> key) {
    _navKey = key;
  }

  static OverlayState? get _overlay => _navKey?.currentState?.overlay;

  /// Show a success snackbar (green).
  static void success(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(type: SnackbarType.success, message: message, duration: duration);
  }

  /// Show an info snackbar (blue).
  static void info(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(type: SnackbarType.info, message: message, duration: duration);
  }

  /// Show an error snackbar (red).
  static void error(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(type: SnackbarType.error, message: message, duration: duration);
  }

  /// Show a warning snackbar (orange).
  static void warning(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(type: SnackbarType.warning, message: message, duration: duration);
  }

  // ── Internal helper ─────────────────────────
  static void _show({
    required SnackbarType type,
    required String message,
    required Duration duration,
  }) {
    final overlay = _overlay;
    if (overlay == null) {
      debugPrint('[CustomSnackbar] overlay is null — '
          'pastikan navigatorKey sudah didaftarkan di MaterialApp.');
      return;
    }

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _SnackbarWidget(
        type: type,
        message: message,
        duration: duration,
        onDismiss: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }
}

// ─────────────────────────────────────────────
//  Internal Snackbar Widget
// ─────────────────────────────────────────────
class _SnackbarWidget extends StatefulWidget {
  const _SnackbarWidget({
    required this.type,
    required this.message,
    required this.duration,
    required this.onDismiss,
  });

  final SnackbarType type;
  final String message;
  final Duration duration;
  final VoidCallback onDismiss;

  @override
  State<_SnackbarWidget> createState() => _SnackbarWidgetState();
}

class _SnackbarWidgetState extends State<_SnackbarWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  Timer? _dismissTimer;

  // ── Per-type design tokens ──────────────────
  static const _configs = {
    SnackbarType.success: _SnackbarConfig(
      borderColor: Color(0xFF2ECC71),
      iconBg: Color(0xFF2ECC71),
      icon: Icons.check_circle_rounded,
    ),
    SnackbarType.info: _SnackbarConfig(
      borderColor: Color(0xFF3B82F6),
      iconBg: Color(0xFF3B82F6),
      icon: Icons.info_rounded,
    ),
    SnackbarType.error: _SnackbarConfig(
      borderColor: Color(0xFFEF4444),
      iconBg: Color(0xFFEF4444),
      icon: Icons.cancel_rounded,
    ),
    SnackbarType.warning: _SnackbarConfig(
      borderColor: Color(0xFFF97316),
      iconBg: Color(0xFFF97316),
      icon: Icons.warning_amber_rounded,
    ),
  };

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    // Slide from bottom (positive Y offset → 0)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Slide in
    _controller.forward();

    // Auto-dismiss
    _dismissTimer = Timer(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    _dismissTimer?.cancel();
    if (!mounted) return;

    await _controller.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInCubic,
    );

    if (mounted) widget.onDismiss();
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = _configs[widget.type]!;
    final mediaQuery = MediaQuery.of(context);
    // viewInsets.bottom = tinggi keyboard (0 kalau keyboard tutup)
    // padding.bottom    = safe area (home indicator, notch bawah)
    // Ambil yang terbesar agar snackbar selalu di atas keduanya
    final bottomOffset = mediaQuery.viewInsets.bottom > 0
        ? mediaQuery.viewInsets.bottom + 12 // di atas keyboard + sedikit jarak
        : mediaQuery.padding.bottom + 24; // normal: di atas safe area

    return Positioned(
      left: 16,
      right: 16,
      bottom: bottomOffset,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: config.borderColor, width: 1.6),
                boxShadow: [
                  BoxShadow(
                    color: config.borderColor.withOpacity(0.18),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  // ── Icon badge ─────────────────
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: config.iconBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      config.icon,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // ── Message ────────────────────
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1A1A1A),
                        height: 1.4,
                      ),
                    ),
                  ),

                  // ── Close button ───────────────
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _dismiss,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3A3A3A),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Config data class (compile-time const)
// ─────────────────────────────────────────────
class _SnackbarConfig {
  const _SnackbarConfig({
    required this.borderColor,
    required this.iconBg,
    required this.icon,
  });

  final Color borderColor;
  final Color iconBg;
  final IconData icon;
}
