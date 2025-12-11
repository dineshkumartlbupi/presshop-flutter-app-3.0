import 'package:flutter/material.dart';

class ValidationIndicator extends StatelessWidget {
  final bool? isValid;
  final String? message;
  final Color? validColor;
  final Color? invalidColor;

  const ValidationIndicator({
    super.key,
    this.isValid,
    this.message,
    this.validColor,
    this.invalidColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isValid == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            isValid! ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: isValid! ? (validColor ?? Colors.green) : (invalidColor ?? Colors.red),
          ),
          const SizedBox(width: 4),
          if (message != null)
            Expanded(
              child: Text(
                message!,
                style: TextStyle(
                  fontSize: 12,
                  color: isValid! ? (validColor ?? Colors.green) : (invalidColor ?? Colors.red),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  final bool showText;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
    this.showText = true,
  });

  PasswordStrength _getStrength() {
    if (password.isEmpty) return PasswordStrength.none;
    if (password.length < 6) return PasswordStrength.weak;
    
    int strength = 0;
    if (password.length >= 8) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;

    if (strength <= 2) return PasswordStrength.weak;
    if (strength <= 3) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  @override
  Widget build(BuildContext context) {
    final strength = _getStrength();
    if (strength == PasswordStrength.none) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: strength.value,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(strength.color),
                  minHeight: 4,
                ),
              ),
            ],
          ),
          if (showText) ...[
            const SizedBox(height: 4),
            Text(
              strength.label,
              style: TextStyle(
                fontSize: 12,
                color: strength.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

enum PasswordStrength {
  none(0.0, Colors.grey, 'None'),
  weak(0.33, Colors.red, 'Weak'),
  medium(0.66, Colors.orange, 'Medium'),
  strong(1.0, Colors.green, 'Strong');

  final double value;
  final Color color;
  final String label;

  const PasswordStrength(this.value, this.color, this.label);
}
