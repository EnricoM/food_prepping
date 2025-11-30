import 'package:flutter/material.dart';

/// A widget that displays a network image with proper error handling
/// for network connectivity issues and other failures.
/// 
/// When the image fails to load (e.g., no internet connection, invalid URL),
/// it displays a fallback placeholder instead of showing an exception.
class NetworkImageWithFallback extends StatelessWidget {
  const NetworkImageWithFallback({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.fallback,
  });

  /// The URL of the image to load
  final String imageUrl;

  /// Optional width for the image
  final double? width;

  /// Optional height for the image
  final double? height;

  /// How the image should be fitted within its bounds
  final BoxFit fit;

  /// Optional border radius for the image
  final BorderRadius? borderRadius;

  /// Custom placeholder widget shown while loading
  final Widget? placeholder;

  /// Custom fallback widget shown when image fails to load
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget imageWidget = Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        // Handle any error (network failure, invalid URL, etc.)
        return _buildFallback(context, theme);
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        
        // Show placeholder while loading
        if (placeholder != null) {
          return placeholder!;
        }
        
        return _buildLoadingPlaceholder(context, theme, loadingProgress);
      },
      // Add frameBuilder to catch errors during image decoding
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }
        return _buildLoadingPlaceholder(context, theme, null);
      },
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildFallback(BuildContext context, ThemeData theme) {
    if (fallback != null) {
      return fallback!;
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade200,
            Colors.grey.shade100,
          ],
        ),
        borderRadius: borderRadius ?? BorderRadius.zero,
      ),
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey.shade400,
        size: _getIconSize(),
      ),
    );
  }

  Widget _buildLoadingPlaceholder(
    BuildContext context,
    ThemeData theme,
    ImageChunkEvent? loadingProgress,
  ) {
    if (placeholder != null) {
      return placeholder!;
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade200,
            Colors.grey.shade100,
          ],
        ),
        borderRadius: borderRadius ?? BorderRadius.zero,
      ),
      child: Center(
        child: loadingProgress != null
            ? CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              )
            : CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
      ),
    );
  }

  double _getIconSize() {
    if (width != null && height != null) {
      return (width! < height! ? width! : height!) * 0.4;
    }
    if (width != null) return width! * 0.4;
    if (height != null) return height! * 0.4;
    return 40;
  }
}

