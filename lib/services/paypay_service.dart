import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PayPayService {
  
  /// PayPayで寄付を開始する
  static Future<PayPayResult> startDonation({
    required int amount,
    required String donationId,
  }) async {
    debugPrint('PayPayサービス: 寄付開始 - 金額: ¥$amount, ID: $donationId');
    
    try {
      // Step 1: PayPayアプリがインストールされているかチェック
      final isInstalled = await _isPayPayInstalled();
      
      if (!isInstalled) {
        debugPrint('PayPayサービス: PayPayアプリが見つかりません');
        return PayPayResult.notInstalled();
      }
      
      // Step 2: PayPayアプリを起動
      final success = await _launchPayPayApp(amount: amount, donationId: donationId);
      
      if (success) {
        debugPrint('PayPayサービス: PayPayアプリ起動成功');
        return PayPayResult.launched();
      } else {
        debugPrint('PayPayサービス: PayPayアプリ起動失敗');
        return PayPayResult.launchFailed();
      }
      
    } catch (e) {
      debugPrint('PayPayサービス: エラー発生 - $e');
      return PayPayResult.error(e.toString());
    }
  }
  
  /// PayPayアプリがインストールされているかチェック
  static Future<bool> _isPayPayInstalled() async {
    // PayPayアプリのカスタムURLスキーム
    final paypayUri = Uri.parse('paypay://');
    
    try {
      final canLaunch = await canLaunchUrl(paypayUri);
      debugPrint('PayPayサービス: インストール確認 - $canLaunch');
      return canLaunch;
    } catch (e) {
      debugPrint('PayPayサービス: インストール確認エラー - $e');
      return false;
    }
  }
  
  /// PayPayアプリを起動
  static Future<bool> _launchPayPayApp({
    required int amount,
    required String donationId,
  }) async {
    // PayPay URL Schemeの構築
    final paypayUrl = _buildPayPayUrl(amount: amount, donationId: donationId);
    final uri = Uri.parse(paypayUrl);
    
    try {
      debugPrint('PayPayサービス: URL起動 - $paypayUrl');
      
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // 外部アプリで起動
      );
      
      return true;
    } catch (e) {
      debugPrint('PayPayサービス: URL起動エラー - $e');
      return false;
    }
  }
  
  /// PayPay用URLを生成
  static String _buildPayPayUrl({
    required int amount,
    required String donationId,
  }) {
    // PayPayのURL Schemeフォーマット
    // 注意: これは例です。実際のPayPayのURL Schemeは公式ドキュメントを確認してください
    
    final baseUrl = 'paypay://payment';
    final params = <String, String>{
      'amount': amount.toString(),
      'currency': 'JPY',
      'reference': donationId,
      'description': 'Future Seedsへの寄付',
      'callback': 'futureseeds://donation/complete', // 決済後の戻り先
    };
    
    final queryString = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
    
    return '$baseUrl?$queryString';
  }
  
  /// PayPayアプリストアに誘導
  static Future<void> openPayPayStore() async {
    const playStoreUrl = 'https://play.google.com/store/apps/details?id=jp.ne.paypay.android.app';
    const appStoreUrl = 'https://apps.apple.com/jp/app/paypay/id1435783608';
    
    // プラットフォーム判定は簡易実装
    final storeUrl = Uri.parse(playStoreUrl); // Androidの場合
    
    try {
      await launchUrl(storeUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('PayPayサービス: アプリストア起動エラー - $e');
    }
  }
}

/// PayPay操作の結果を表すクラス
class PayPayResult {
  final PayPayStatus status;
  final String? errorMessage;
  
  const PayPayResult._(this.status, [this.errorMessage]);
  
  // 成功パターン
  factory PayPayResult.launched() => const PayPayResult._(PayPayStatus.launched);
  
  // エラーパターン
  factory PayPayResult.notInstalled() => const PayPayResult._(PayPayStatus.notInstalled);
  factory PayPayResult.launchFailed() => const PayPayResult._(PayPayStatus.launchFailed);
  factory PayPayResult.error(String message) => PayPayResult._(PayPayStatus.error, message);
  
  bool get isSuccess => status == PayPayStatus.launched;
  bool get isNotInstalled => status == PayPayStatus.notInstalled;
  bool get isError => status == PayPayStatus.error || status == PayPayStatus.launchFailed;
}

enum PayPayStatus {
  launched,      // PayPayアプリ起動成功
  notInstalled,  // PayPayアプリ未インストール
  launchFailed,  // 起動失敗
  error,         // その他エラー
}