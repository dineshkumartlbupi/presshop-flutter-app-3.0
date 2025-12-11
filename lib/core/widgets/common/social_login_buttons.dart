import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final String text;
  final String? iconPath;
  final IconData? icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? height;
  final double? borderRadius;

  const SocialLoginButton({
    super.key,
    required this.text,
    this.iconPath,
    this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 50,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.white,
          side: BorderSide(color: borderColor ?? Colors.grey[300]!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconPath != null)
              Image.asset(
                iconPath!,
                height: 24,
                width: 24,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    icon ?? Icons.login,
                    size: 24,
                    color: textColor ?? Colors.black87,
                  );
                },
              )
            else if (icon != null)
              Icon(
                icon,
                size: 24,
                color: textColor ?? Colors.black87,
              ),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor ?? Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SocialLoginButton(
      text: 'Continue with Google',
      iconPath: 'assets/icons/google.png',
      icon: Icons.g_mobiledata,
      onPressed: onPressed,
    );
  }
}

class FacebookSignInButton extends StatelessWidget {
  final VoidCallback onPressed;

  const FacebookSignInButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SocialLoginButton(
      text: 'Continue with Facebook',
      iconPath: 'assets/icons/facebook.png',
      icon: Icons.facebook,
      onPressed: onPressed,
      textColor: const Color(0xFF1877F2),
    );
  }
}

class AppleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AppleSignInButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SocialLoginButton(
      text: 'Continue with Apple',
      iconPath: 'assets/icons/apple.png',
      icon: Icons.apple,
      onPressed: onPressed,
    );
  }
}
