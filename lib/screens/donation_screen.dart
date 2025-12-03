import 'package:flutter/material.dart';
import '../services/paypay_service.dart';

class DonationScreen extends StatefulWidget {
  const DonationScreen({super.key});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  // 選択可能な寄付金額
  static const List<int> _donationAmounts = [
    500, 1000, 2000, 3000, 5000, 10000
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('寄付・支援'),
        elevation: 0,
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー説明
            _buildHeaderSection(),
            
            const SizedBox(height: 32),
            
            // PayPay寄付セクション
            _buildPayPaySection(),
            
            const SizedBox(height: 32),
            
            // その他の寄付方法
            _buildOtherMethodsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite, color: Colors.green[600], size: 24),
              const SizedBox(width: 8),
              Text(
                'Future Seeds を支援',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '皆様からの温かいご支援が、食品ロス削減と困っている方々への支援活動を支えています。',
            style: TextStyle(
              fontSize: 16,
              color: Colors.green[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayPaySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.payment, color: Colors.red[600], size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'PayPayで簡単寄付',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        Text(
          '金額を選んでワンタップで寄付できます',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 金額選択ボタン
        GridView.builder(
          shrinkWrap: true,         //親のサイズに合わせる
          physics: const NeverScrollableScrollPhysics(),  //スクロール無効
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,      // 2列表示
            crossAxisSpacing: 12,   // 列間隔
            mainAxisSpacing: 12,    // 行間隔
            childAspectRatio: 2.9,  // 幅：高さ比
          ),
          itemCount: _donationAmounts.length,
          itemBuilder: (context, index) {
            final amount = _donationAmounts[index];
            return _buildAmountButton(amount);
          },
        ),
      ],
    );
  }

  Widget _buildAmountButton(int amount) {
    return ElevatedButton(
      onPressed: () => _startPayPayDonation(amount),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red[50],
        foregroundColor: Colors.red[700],
        elevation: 0,
        side: BorderSide(color: Colors.red[200]!),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '¥${_formatAmount(amount)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherMethodsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'その他の支援方法',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        _buildDonationMethod(
          icon: Icons.account_balance,
          title: '銀行振込',
          description: '銀行口座への直接振込',
          onTap: _showBankInfo,
        ),
      ],
    );
  }

  Widget _buildDonationMethod({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.grey[600]),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  // PayPay寄付を開始
  Future<void> _startPayPayDonation(int amount) async {
    debugPrint('寄付開始: PayPay, 金額: ¥$amount');
    
    // ローディング表示
    showDialog(
      context: context,
      barrierDismissible: false,  //背景タップで閉じない
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    try {
      // 一意の寄付IDを生成
      final donationId = 'donation_${DateTime.now().millisecondsSinceEpoch}';
      
      // PayPayサービスを使って寄付開始
      final result = await PayPayService.startDonation(
        amount: amount,
        donationId: donationId,
      );
      
      // ローディングを閉じる
      if (mounted) Navigator.pop(context);
      
      // 結果に応じた処理
      if (result.isSuccess) {
        _showPayPayLaunchedDialog(amount);
      } else if (result.isNotInstalled) {
        _showPayPayNotInstalledDialog();
      } else {
        _showErrorDialog('PayPay起動エラー', result.errorMessage ?? '不明なエラーが発生しました');
      }
      
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showErrorDialog('エラー', 'システムエラーが発生しました: $e');
    }
  }

  //PayPay起動成功時
  void _showPayPayLaunchedDialog(int amount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.payment, color: Colors.red[600], size: 48),
        title: const Text('PayPayを起動しました'),
        content: Column(
          mainAxisSize: MainAxisSize.min,  //必要最小限のサイズ
          children: [
            Text('¥${_formatAmount(amount)}の寄付手続きをPayPayアプリで完了してください。'),
            const SizedBox(height: 16),
            const Text(
              '決済完了後、このアプリに戻ってきてください。',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('確認'),
          ),
        ],
      ),
    );
  }

  //PayPay未インストール時
  void _showPayPayNotInstalledDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.warning, color: Colors.orange[600], size: 48),
        title: const Text('PayPayアプリが必要です'),
        content: const Text(
          'PayPay決済にはPayPayアプリのインストールが必要です。\n\nアプリストアからPayPayをダウンロードしてください。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),

          //アプリストアへ
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              PayPayService.openPayPayStore();
            },
            child: const Text('PayPayをダウンロード'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.error, color: Colors.red[600], size: 48),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('確認'),
          ),
        ],
      ),
    );
  }

  // 金額をカンマ区切りでフォーマット
  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), //正規表現パターン
      (Match m) => '${m[1]},',                //三桁区切りカンマ
    );
  }

  void _showBankInfo() {
    // 既存の銀行口座情報表示実装
  }
}