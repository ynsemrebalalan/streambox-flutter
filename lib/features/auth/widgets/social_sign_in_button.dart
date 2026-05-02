import 'package:flutter/material.dart';

enum SocialProvider { google, apple }

/// Apple HIG / Material 3 paritesi için ortak social sign-in butonu.
class SocialSignInButton extends StatelessWidget {
  final SocialProvider provider;
  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  const SocialSignInButton({
    super.key,
    required this.provider,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isApple = provider == SocialProvider.apple;
    final fg = isApple ? Colors.white : Colors.black87;
    final bg = isApple ? Colors.black : Colors.white;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: fg,
          backgroundColor: bg,
          side: BorderSide(
              color: isApple ? Colors.black : Colors.black26, width: 1),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        icon: loading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(fg)),
              )
            : _ProviderIcon(provider: provider),
        label: Text(
          label,
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600, color: fg),
        ),
      ),
    );
  }
}

class _ProviderIcon extends StatelessWidget {
  final SocialProvider provider;
  const _ProviderIcon({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider == SocialProvider.apple) {
      // Material'de Apple logosu yok; iOS-style yaklaşımı için emoji yerine
      // basit Apple silüeti kullanmak yerine "" benzeri unicode sınırlı.
      // Gerçek production'da apple_logo asset eklenir; şimdilik genel ikon.
      return const Icon(Icons.apple, size: 22);
    }
    // Google için renkli "G" — ideal vendor SVG, şimdilik kontrast renkli text.
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      alignment: Alignment.center,
      child: const Text(
        'G',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF4285F4),
        ),
      ),
    );
  }
}
