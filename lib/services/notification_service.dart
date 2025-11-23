import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // 通知の許可をリクエスト
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
      print('通知権限が許可されました');

      // iOS用の追加設定
      if (Platform.isIOS) {
        try {
          // APNSトークンの取得を待つ（タイムアウト付き）
          await _messaging.getAPNSToken().timeout(
            const Duration(seconds: 3),
            onTimeout: () {
              print('APNSトークンの取得がタイムアウトしました（シミュレータでは正常です）');
              return null;
            },
          );
        } catch (e) {
          print('APNSトークン取得エラー（シミュレータでは正常です）: $e');
        }
      }

      // FCMトークンを取得
      try {
        String? token = await _messaging.getToken();
        print('FCM Token: $token');
      } catch (e) {
        print('FCMトークン取得エラー: $e');
      }
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }


    // フォアグラウンドでのメッセージ受信
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint('Message also contained a notification: ${message.notification}');
      }
    });

    // バックグラウンドメッセージハンドラー
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('トピック購読成功: $topic');
    } catch (e) {
      debugPrint('トピック購読エラー: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('トピック購読解除成功: $topic');
    } catch (e) {
      debugPrint('トピック購読解除エラー: $e');
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message: ${message.messageId}');
}
