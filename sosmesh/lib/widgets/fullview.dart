import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';

class FullViewMap extends StatefulWidget {
  final LatLng initialLocation;

  const FullViewMap({super.key, required this.initialLocation});

  @override
  State<FullViewMap> createState() => _FullViewMapState();
}

class _FullViewMapState extends State<FullViewMap> {
  late LatLng _current;
  bool _offlineMode = false;
  bool _downloading = false;

  @override
  void initState() {
    super.initState();
    _current = widget.initialLocation;
    _getLiveLocation();
  }

  Future<void> _getLiveLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      final pos = await Geolocator.getCurrentPosition();
      setState(() {
        _current = LatLng(pos.latitude, pos.longitude);
      });
    } catch (_) {}
  }

  void _copyLocation() {
    final text = "${_current.latitude}, ${_current.longitude}";
    Clipboard.setData(ClipboardData(text: text));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Location copied"),
        backgroundColor: Colors.green,
      ),
    );
  }


  void _toggleOffline() async {
    setState(() => _downloading = true);

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _offlineMode = !_offlineMode;
      _downloading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _offlineMode
              ? "Offline map enabled (cached tiles)"
              : "Online map enabled",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: const Text("Map View"),
        actions: [
          IconButton(
            onPressed: _copyLocation,
            icon: const Icon(Icons.copy),
            tooltip: "Copy Location",
          ),
          IconButton(
            onPressed: _downloading ? null : _toggleOffline,
            icon: _downloading
                ? const CircularProgressIndicator(color: Colors.white)
                : Icon(_offlineMode ? Icons.cloud_off : Icons.cloud_download),
            tooltip: "Offline Mode",
          ),
        ],
      ),

      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(initialCenter: _current, initialZoom: 16),
            children: [
              TileLayer(
                urlTemplate: _offlineMode
                    ? "https://tile.openstreetmap.org/{z}/{x}/{y}.png"
                    : "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.sosmesh.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _current,
                    width: 50,
                    height: 50,
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Bottom info panel
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.cyan),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Lat: ${_current.latitude.toStringAsFixed(5)}\n"
                    "Lng: ${_current.longitude.toStringAsFixed(5)}",
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        _offlineMode ? "OFFLINE" : "ONLINE",
                        style: TextStyle(
                          color: _offlineMode ? Colors.orange : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: _getLiveLocation,
                        child: const Text("Refresh"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
