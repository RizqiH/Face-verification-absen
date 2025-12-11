import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Custom button widget following Material Design 3 principles
/// Provides consistent styling across the app
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonType type;
  final IconData? icon;
  final bool fullWidth;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.type = ButtonType.primary,
    this.icon,
    this.fullWidth = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final button = icon != null
        ? ElevatedButton.icon(
            onPressed: isLoading ? null : onPressed,
            icon: _buildContent(isIcon: true),
            label: _buildContent(),
            style: _getButtonStyle(context),
          )
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: _getButtonStyle(context),
            child: _buildContent(),
          );

    return fullWidth
        ? SizedBox(
            width: double.infinity,
            child: button,
          )
        : button;
  }

  Widget _buildContent({bool isIcon = false}) {
    if (isIcon && icon != null) {
      return Icon(icon);
    }

    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    final defaultPadding = padding ??
        const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        );

    switch (type) {
      case ButtonType.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[300],
          disabledForegroundColor: Colors.grey[600],
          padding: defaultPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        );

      case ButtonType.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.primaryColor,
          disabledBackgroundColor: Colors.grey[100],
          disabledForegroundColor: Colors.grey[400],
          padding: defaultPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(
              color: AppTheme.primaryColor,
              width: 1.5,
            ),
          ),
          elevation: 0,
        );

      case ButtonType.danger:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[300],
          disabledForegroundColor: Colors.grey[600],
          padding: defaultPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        );

      case ButtonType.text:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppTheme.primaryColor,
          disabledForegroundColor: Colors.grey[400],
          padding: defaultPadding,
          elevation: 0,
          shadowColor: Colors.transparent,
        );
    }
  }
}

/// Button types for different use cases
enum ButtonType {
  primary,
  secondary,
  danger,
  text,
}

