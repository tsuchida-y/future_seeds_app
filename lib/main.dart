import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; 
import 'screens/map_screen.dart';
import 'screens/news_screen.dart';
import 'screens/donation_screen.dart';
import 'services/notification_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // .envファイルを読み込み
  await dotenv.load(fileName: ".env");

  // iOS用: Google Maps APIキーをネイティブ側に送信
  if (Platform.isIOS) {
    try {
      debugPrint('App: iOS用Google Maps APIキー設定中...');
      //通信チャンネルの作成(ネイティブとの通信用の橋)
      const platform = MethodChannel('com.futureseeds.app/config');
      final apiKey = dotenv.env['GOOGLE_MAPS_IOS_API_KEY'] ?? '';
      
      if (apiKey.isNotEmpty) {
        //Dartからネイティブ側にAPIキーを送信
        //invokeMethod(ネイティブで使用するメソッド,送信するデータ)
        await platform.invokeMethod('getGoogleMapsApiKey', {'apiKey': apiKey});
        debugPrint('App: iOS用APIキー設定完了');
      } else {
        debugPrint('App: 警告 - iOS用APIキーが.envに設定されていません');
      }
    } catch (e) {
      debugPrint('App: エラー - iOS用APIキー設定失敗: $e');
    }
  }

  // Firebaseの初期化
  try {
    debugPrint('App: Firebase初期化中...');
    await Firebase.initializeApp(
       options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('App: Firebase初期化成功');
  } catch (e) {
    debugPrint('App: エラー - Firebase初期化失敗: $e');
  }
  
  // プッシュ通知の初期化
  try {
    debugPrint('App: プッシュ通知初期化中...');
    final notificationService = NotificationService();
    await notificationService.initialize();
    await notificationService.subscribeToTopic('all_users');
    debugPrint('App: プッシュ通知初期化成功');
  } catch (e) {
    debugPrint('App: エラー - プッシュ通知初期化失敗: $e');
  }
  
  runApp(const FutureSeedsApp());
}

class FutureSeedsApp extends StatelessWidget {
  const FutureSeedsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Future Seeds',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50), // 温かみのある緑色
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Noto Sans JP', // 日本語フォント（要設定）
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const MapScreen(),
    const NewsScreen(),
    const DonationScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'マップ',
          ),
          NavigationDestination(
            icon: Icon(Icons.newspaper_outlined),
            selectedIcon: Icon(Icons.newspaper),
            label: 'お知らせ',
          ),
          NavigationDestination(
            icon: Icon(Icons.volunteer_activism_outlined),
            selectedIcon: Icon(Icons.volunteer_activism),
            label: '寄付',
          ),
        ],
      ),
    );
  }
}
