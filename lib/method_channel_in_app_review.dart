import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'in_app_review_platform_interface.dart';

/// An implementation of [InAppReviewPlatform] that uses method channels.
class MethodChannelInAppReview extends InAppReviewPlatform {
  MethodChannel _channel = MethodChannel('dev.britannio.in_app_review');

  @visibleForTesting
  set channel(MethodChannel channel) => _channel = channel;


  @override
  Future<bool> isAvailable() async {
    if (kIsWeb) return false;
    return _channel
        .invokeMethod<bool>('isAvailable')
        .then((available) => available ?? false, onError: (_) => false);
  }

  @override
  Future<bool> requestReview() async {
    return await _channel.invokeMethod('requestReview');
  }

  @override
  Future<void> openStoreListing({
    String? appStoreId,
    String? microsoftStoreId,
  }) async {
    final bool isIOS = Platform.isIOS;
    final bool isMacOS = Platform.isMacOS;
    final bool isAndroid = Platform.isAndroid;
    final bool isWindows = Platform.isWindows;

    if (isIOS || isMacOS) {
      await _channel.invokeMethod(
        'openStoreListing',
        ArgumentError.checkNotNull(appStoreId, 'appStoreId'),
      );
    } else if (isAndroid) {
      await _channel.invokeMethod('openStoreListing');
    } else if (isWindows) {
      ArgumentError.checkNotNull(microsoftStoreId, 'microsoftStoreId');
      await _launchUrl(
        'ms-windows-store://review/?ProductId=$microsoftStoreId',
      );
    } else {
      throw UnsupportedError(
        'Platform(${Platform.operatingSystem}) not supported',
      );
    }
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false, forceWebView: false);
    }
  }
}
