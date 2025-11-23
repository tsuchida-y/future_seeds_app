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
    _requestLocationPermission();
    _loadSpots();
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
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
    _spotService.getSpots().listen((spots) {
      setState(() {
        _spots = spots;
        _updateMarkers();
      });
    });
  }

  void _updateMarkers() {
    _markers.clear();
    for (var spot in _spots) {
      _markers.add(
        Marker(
          markerId: MarkerId(spot.id),
          position: LatLng(spot.latitude, spot.longitude),
          infoWindow: InfoWindow(
            title: spot.name,
            snippet: spot.typeLabel,
            onTap: () => _showSpotDetail(spot),
          ),
          icon: _getMarkerIcon(spot.type),
        ),
      );
    }
  }

  BitmapDescriptor _getMarkerIcon(SpotType type) {
    // ここでは色で区別（実際のアプリではカスタムアイコンを推奨）
    switch (type) {
      case SpotType.communityFridge:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      case SpotType.foodCollectionBox:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case SpotType.donationBox:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    }
  }

  void _showSpotDetail(Spot spot) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
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
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 16),
                
                // スポット名
                Text(
                  spot.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                
                // スポットタイプ
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
                const SizedBox(height: 16),
                
                // 住所
                _buildInfoRow(Icons.location_on, spot.address),
                const SizedBox(height: 8),
                
                // 受付時間
                _buildInfoRow(Icons.access_time, spot.openingHours),
                const SizedBox(height: 16),
                
                // 募集している食品
                if (spot.neededItems.isNotEmpty) ...[
                  const Text(
                    '募集している食品',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: spot.neededItems
                        .map((item) => Chip(
                              label: Text(item),
                              backgroundColor: Colors.green[50],
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // 説明
                if (spot.description != null) ...[
                  const Text(
                    '詳細',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(spot.description!),
                  const SizedBox(height: 16),
                ],
                
                // ルート案内ボタン
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openMapsApp(spot),
                    icon: const Icon(Icons.directions),
                    label: const Text('ルート案内'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
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

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
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
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) => _mapController = controller,
            initialCameraPosition: const CameraPosition(
              target: LatLng(35.6762, 139.6503), // 東京の座標
              zoom: 12,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            compassEnabled: true,
            mapToolbarEnabled: false,
          ),
          
          // フィルターボタン（オプション）
          Positioned(
            top: 50,
            right: 16,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterOptions,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions() {
    // フィルターオプションを表示（実装はオプション）
  }
}
