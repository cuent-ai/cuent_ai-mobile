import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey[600])),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'O continúa con',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey[600])),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildSocialButton(
                icon: Icons.g_mobiledata,
                label: 'Google',
                color: AppTheme.errorColor,
                onTap: () => _handleSocialLogin('Google'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSocialButton(
                icon: Icons.apple,
                label: 'Apple',
                color: Colors.white,
                onTap: () => _handleSocialLogin('Apple'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[700]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSocialLogin(String provider) {
    // Implement social login logic here
    print('Login with $provider');
  }
}
