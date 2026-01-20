import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/spot.dart';
import '../services/spot_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  final SpotService _spotService = SpotService();
  final Set<Marker> _markers = {};
  List<Spot> _spots = [];
  Spot? _selectedSpot; // 選択されたスポット

  @override
  void initState() {
    super.initState();
    debugPrint('===== MapScreen: 初期化開始 =====');
    _requestLocationPermission();
    _loadSpots();
  }

  Future<void> _requestLocationPermission() async {
    debugPrint('MapScreen: 位置情報パーミッション要求中...');
    final status = await Permission.location.request();
    debugPrint('MapScreen: パーミッション結果 = $status');

    if (status.isGranted) {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      debugPrint('MapScreen: 現在地取得中...');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      debugPrint('MapScreen: 現在地取得成功 - 緯度: ${position.latitude}, 経度: ${position.longitude}');

      setState(() {
        _currentPosition = position;
      });

      debugPrint('MapScreen: カメラを現在地に移動中...');
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(position.latitude, position.longitude),
        ),
      );
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  void _loadSpots() {
    debugPrint('MapScreen: Firestoreからスポットデータ取得開始...');
    _spotService.getSpots().listen((spots) {
      debugPrint('MapScreen: スポットデータ受信 - ${spots.length}件');
      setState(() {
        _spots = spots;
        _updateMarkers();
      });
    });
  }

  void _updateMarkers() {
    debugPrint('MapScreen: マーカー更新開始 - ${_spots.length}個のスポットをマーカーに変換');
    _markers.clear();

    for (var spot in _spots) {
      _markers.add(
        Marker(
          markerId: MarkerId(spot.id),
          position: LatLng(spot.latitude, spot.longitude),
          icon: _getMarkerIcon(spot.type),
          // infoWindowは使用せず、タップイベントで詳細を表示
          onTap: () {
            setState(() {
              _selectedSpot = spot;
            });
            // カメラを選択されたマーカーに移動
            _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(
                LatLng(spot.latitude, spot.longitude),
                15,
              ),
            );
          },
        ),
      );
    }
  }

  BitmapDescriptor _getMarkerIcon(SpotType type) {
    switch (type) {
      case SpotType.communityFridge:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      case SpotType.foodCollectionBox:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case SpotType.donationBox:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    }
  }

  String _calculateDistance(Spot spot) {
    if (_currentPosition == null) return '距離不明';
    
    final distance = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      spot.latitude,
      spot.longitude,
    );
    
    if (distance < 1000) {
      return '${distance.toInt()}m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}km';
    }
  }

  Color _getTypeColor(SpotType type) {
    switch (type) {
      case SpotType.communityFridge:
        return Colors.blue;
      case SpotType.foodCollectionBox:
        return Colors.green;
      case SpotType.donationBox:
        return Colors.orange;
    }
  }

  Future<void> _openMapsApp(Spot spot) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${spot.latitude},${spot.longitude}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('MapScreen: 画面を描画中... (マーカー数: ${_markers.length})');
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) => _mapController = controller,
            initialCameraPosition: const CameraPosition(
              target: LatLng(39.7036, 141.1527),
              zoom: 13,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            compassEnabled: true,
            mapToolbarEnabled: false,
            // 地図タップで選択解除
            onTap: (_) {
              setState(() {
                _selectedSpot = null;
              });
            },
          ),
          
          // Google Mapsスタイルの情報カード
          if (_selectedSpot != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 100,
              child: _buildSpotInfoCard(_selectedSpot!),
            ),
        ],
      ),
    );
  }

  Widget _buildSpotInfoCard(Spot spot) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 画像部分
          if (spot.imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                spot.imageUrl!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 160,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.broken_image,
                      size: 64,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // タイトル行（名前とタイプバッジ）
                Column(  // ← Rowから変更
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      spot.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),  // ← widthからheightに変更
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getTypeColor(spot.type),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        spot.typeLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // 距離と営業状態
                Row(
                  children: [
                    Icon(Icons.route, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      _calculateDistance(spot),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.access_time, size: 16, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      '営業中',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // 住所
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on, size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        spot.address,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // 営業時間
                Row(
                  children: [
                    Icon(Icons.schedule, size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      spot.openingHours,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                
                // 募集している食品（最大3つまで表示）
                if (spot.neededItems.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.inventory_2, size: 18, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: spot.neededItems
                              .take(3)
                              .map((item) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.green[200]!,
                                      ),
                                    ),
                                    child: Text(
                                      item,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.green[800],
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ],
                
                const SizedBox(height: 16),
                
                // アクションボタン
                Row(
                  children: [
                    // ルート案内ボタン
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openMapsApp(spot),
                        icon: const Icon(Icons.directions, size: 20),
                        label: const Text(
                          'ルート案内',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // 詳細ボタン
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showFullSpotDetail(spot),
                        icon: const Icon(Icons.info_outline, size: 20),
                        label: const Text(
                          '詳細を見る',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Colors.blue, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFullSpotDetail(Spot spot) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ハンドルバー
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // 画像
                if (spot.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      spot.imageUrl!,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 220,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.broken_image,
                            size: 64,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                
                // スポット名
                Text(
                  spot.name,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                
                // スポットタイプと距離
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getTypeColor(spot.type),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        spot.typeLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.route, size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      _calculateDistance(spot),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                
                const Divider(height: 32),
                
                // 基本情報セクション
                const Text(
                  '基本情報',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                _buildDetailInfoRow(Icons.location_on, '住所', spot.address),
                const SizedBox(height: 12),
                _buildDetailInfoRow(Icons.access_time, '受付時間', spot.openingHours),
                
                // 募集している食品
                if (spot.neededItems.isNotEmpty) ...[
                  const Divider(height: 32),
                  const Text(
                    '募集している食品',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: spot.neededItems
                        .map((item) => Chip(
                              label: Text(
                                item,
                                style: const TextStyle(fontSize: 14),
                              ),
                              backgroundColor: Colors.green[50],
                              side: BorderSide(color: Colors.green[300]!),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                            ))
                        .toList(),
                  ),
                ],
                
                // 説明
                if (spot.description != null && spot.description!.isNotEmpty) ...[
                  const Divider(height: 32),
                  const Text(
                    '詳細',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    spot.description!,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // ルート案内ボタン
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _openMapsApp(spot);
                    },
                    icon: const Icon(Icons.directions, size: 22),
                    label: const Text(
                      'ルート案内を開始',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: Colors.grey[700]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}