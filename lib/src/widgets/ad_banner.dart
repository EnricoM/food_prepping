import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import '../services/subscription_service.dart';

class AdBanner extends StatefulWidget {
  const AdBanner({super.key});

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> with WidgetsBindingObserver {
  BannerAd? _banner;
  bool _loaded = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SubscriptionService.instance.addListener(_onSubscriptionChanged);
    _checkAndLoadAd();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SubscriptionService.instance.removeListener(_onSubscriptionChanged);
    _banner?.dispose();
    super.dispose();
  }

  void _onSubscriptionChanged() {
    _checkAndLoadAd();
  }

  void _checkAndLoadAd() {
    // Only show ads for non-premium users
    if (SubscriptionService.instance.isPremium) {
      _banner?.dispose();
      setState(() {
        _banner = null;
        _loaded = false;
      });
      return;
    }
    if (!_isMobile()) {
      return;
    }
    if (_banner == null) {
      _loadAd();
    }
  }

  void _loadAd() {
    final adUnitId = _getAdUnitId();
    if (kDebugMode) {
      print('AdBanner: Loading ad with unit ID: $adUnitId');
    }
    _banner = BannerAd(
      size: AdSize.banner,
      adUnitId: adUnitId,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (kDebugMode) {
            print('AdBanner: Ad loaded successfully');
          }
          setState(() {
            _loaded = true;
            _errorMessage = null;
          });
        },
        onAdFailedToLoad: (ad, err) {
          if (kDebugMode) {
            print('AdBanner: Failed to load ad: ${err.message}');
            print('AdBanner: Error code: ${err.code}');
            print('AdBanner: Error domain: ${err.domain}');
          }
          ad.dispose();
          setState(() {
            _loaded = false;
            _banner = null;
            _errorMessage = 'Ad failed to load: ${err.message}';
          });
        },
        onAdOpened: (ad) {
          if (kDebugMode) {
            print('AdBanner: Ad opened');
          }
        },
        onAdClosed: (ad) {
          if (kDebugMode) {
            print('AdBanner: Ad closed');
          }
        },
      ),
      request: const AdRequest(),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    // Don't show ads for premium users
    if (SubscriptionService.instance.isPremium) {
      return const SizedBox.shrink();
    }
    
    // Don't show if not mobile
    if (!_isMobile()) {
      return const SizedBox.shrink();
    }
    
    // Show error message in debug mode
    if (kDebugMode && _errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(8),
        color: Colors.red.shade100,
        child: Text(
          _errorMessage!,
          style: TextStyle(color: Colors.red.shade900, fontSize: 12),
        ),
      );
    }
    
    // Only show if ad is loaded
    if (!_loaded || _banner == null) {
      // Show loading indicator in debug mode
      if (kDebugMode) {
        return Container(
          height: 50,
          color: Colors.grey.shade200,
          child: const Center(
            child: Text('Loading ad...', style: TextStyle(fontSize: 12)),
          ),
        );
      }
      return const SizedBox.shrink();
    }
    
    return SizedBox(
      width: _banner!.size.width.toDouble(),
      height: _banner!.size.height.toDouble(),
      child: AdWidget(ad: _banner!),
    );
  }
}

String _getAdUnitId() {
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return 'ca-app-pub-5743498140441400/3104864428';
    case TargetPlatform.iOS:
      // TODO: Replace with real iOS ad unit ID when available
      return 'ca-app-pub-3940256099942544/2934735716';
    default:
      return 'ca-app-pub-5743498140441400/3104864428';
  }
}

bool _isMobile() {
  return !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
}

