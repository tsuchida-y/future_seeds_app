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
          // タップ時にBottomSheetを表示
          onTap: () => _showSpotBottomSheet(spot),
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

  // ピンタップ時に表示するBottomSheet（統合版）
  void _showSpotBottomSheet(Spot spot) {
    // カメラを選択されたマーカーに移動
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(spot.latitude, spot.longitude),
        15,
      ),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSpotBottomSheet(spot),
    );
  }

  // BottomSheetのコンテンツ（統合版：引き上げると詳細が見える）
  Widget _buildSpotBottomSheet(Spot spot) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ハンドルバー
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== 簡易情報（初期表示） =====
                    
                    // タイトル行（名前とタイプバッジ）
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          spot.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
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

                    const SizedBox(height: 16),

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

                    const SizedBox(height: 16),

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

                    const SizedBox(height: 12),

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
                      const SizedBox(height: 16),
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

                    const SizedBox(height: 24),

                    // ルート案内ボタン（フルサイズ）
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _openMapsApp(spot);
                        },
                        icon: const Icon(Icons.directions, size: 20),
                        label: const Text(
                          'ルート案内',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    // ===== 詳細情報（スクロールして表示） =====
                    
                    const SizedBox(height: 32),
                    
                    // 区切り線
                    Divider(color: Colors.grey[300], thickness: 1),
                    
                    const SizedBox(height: 24),
                    
                    // 基本情報セクション
                    const Text(
                      '基本情報',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildDetailInfoRow(Icons.location_on, '住所', spot.address),
                    const SizedBox(height: 16),
                    _buildDetailInfoRow(Icons.access_time, '受付時間', spot.openingHours),
                    
                    // 募集している食品（すべて表示）
                    if (spot.neededItems.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      const Text(
                        '募集している食品',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
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
                      const SizedBox(height: 32),
                      const Text(
                        '詳細',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        spot.description!,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('MapScreen: 画面を描画中... (マーカー数: ${_markers.length})');
    return Scaffold(
      body: GoogleMap(
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