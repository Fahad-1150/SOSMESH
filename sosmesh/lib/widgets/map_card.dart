import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../providers/app_state_provider.dart';
import 'fullview.dart';

class MapCard extends StatefulWidget {
  const MapCard({super.key});

  @override
  State<MapCard> createState() => _MapCardState();
}

class _MapCardState extends State<MapCard> {
  LatLng? _currentLatLng;
  String _locationText = "Getting location...";

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    final provider = context.read<AppStateProvider>();
    final pos = await provider.locationService.getCurrentLocation();

    if (!mounted) return;

    if (pos != null) {
      setState(() {
        _currentLatLng = LatLng(pos.latitude, pos.longitude);
        _locationText =
            "${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}";
      });
    } else {
      setState(() {
        _currentLatLng = const LatLng(23.8103, 90.4125);
        _locationText = "Location unavailable";
      });
    }
  }

  void _openFullMap() {
    if (_currentLatLng == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullViewMap(initialLocation: _currentLatLng!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentLatLng == null) {
      return const CircularProgressIndicator(color: Colors.cyan);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 🗺 MAP CARD
        GestureDetector(
          onTap: _openFullMap,
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.cyan, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: _currentLatLng!,
                      initialZoom: 15,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                        userAgentPackageName: 'com.sosmesh.app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _currentLatLng!,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 35,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      color: Colors.black54,
                      child: Text(
                        _locationText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 6),

        // 🔘 FULL MAP BUTTON
        GestureDetector(
          onTap: _openFullMap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.cyan,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "FULL MAP",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
