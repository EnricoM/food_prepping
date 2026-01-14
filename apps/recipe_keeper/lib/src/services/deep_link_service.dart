import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

/// Service to handle deep links for the app.
/// When a URL is shared to the app, it will be processed here.
class DeepLinkService {
  DeepLinkService._();
  static final DeepLinkService instance = DeepLinkService._();

  final _appLinks = AppLinks();
  final _linkStreamController = StreamController<Uri>.broadcast();
  
  Stream<Uri> get linkStream => _linkStreamController.stream;
  
  bool _initialized = false;

  /// Initialize the deep link service and start listening for links.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // Handle initial link (if app was opened via deep link)
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _linkStreamController.add(initialLink);
      }
    } catch (e) {
      debugPrint('Error getting initial link: $e');
    }

    // Listen for incoming links while app is running
    _appLinks.uriLinkStream.listen(
      (uri) {
        _linkStreamController.add(uri);
      },
      onError: (err) {
        debugPrint('Error in deep link stream: $err');
      },
    );
  }

  void dispose() {
    _linkStreamController.close();
  }
}
