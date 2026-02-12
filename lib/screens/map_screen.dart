import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final CollectionReference markersRef =
      FirebaseFirestore.instance.collection('markers');

  final MapController mapController = MapController();

  String searchText = '';
  LatLng? selectedPoint;

  /// ➕ Add marker
  Future<void> _addMarkerWithName(LatLng point) async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Smart Bin'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Bin name',
            hintText: 'e.g. Building A',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;

              await markersRef.add({
                'name': name,
                'lat': point.latitude,
                'lng': point.longitude,
                'createdAt': Timestamp.now(),
              });

              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  /// ✏️ Edit marker name
  Future<void> _editMarkerName(String docId, String oldName) async {
    final controller = TextEditingController(text: oldName);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Bin Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Bin name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty) return;

              await markersRef.doc(docId).update({
                'name': newName,
              });

              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  /// 🗑️ Delete marker
  Future<void> _deleteMarker(String docId, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete marker?'),
        content: Text('Delete "$name" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await markersRef.doc(docId).delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🗑️ Marker deleted'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void _moveToMarker(LatLng point) {
    mapController.move(point, 17);
    setState(() => selectedPoint = point);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Bin Map'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          // 🔍 Search bar
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search bin name...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) =>
                  setState(() => searchText = v.toLowerCase()),
            ),
          ),

          Expanded(
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: const LatLng(13.7563, 100.5018),
                initialZoom: 13,
                onTap: (tapPosition, point) {
                  _addMarkerWithName(point);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName:
                      'com.example.flutter_application_1',
                ),

                /// 📍 Marker Layer
                StreamBuilder<QuerySnapshot>(
                  stream: markersRef.snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();

                    final markers = snapshot.data!.docs
                        .map((doc) {
                          final data =
                              doc.data() as Map<String, dynamic>;

                          final name = (data['name'] ?? '').toString();
                          final lat = data['lat'];
                          final lng = data['lng'];

                          if (name.isEmpty ||
                              lat == null ||
                              lng == null) {
                            return null;
                          }

                          if (!name
                              .toLowerCase()
                              .contains(searchText)) {
                            return null;
                          }

                          final point = LatLng(lat, lng);

                          return Marker(
                            point: point,
                            width: 140,
                            height: 90,
                            child: GestureDetector(
                              onTap: () => _moveToMarker(point),
                              onDoubleTap: () =>
                                  _editMarkerName(doc.id, name),
                              onLongPress: () =>
                                  _deleteMarker(doc.id, name),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.location_pin,
                                    color: selectedPoint == point
                                        ? Colors.green
                                        : Colors.red,
                                    size: 40,
                                  ),
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(6),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 4,
                                        )
                                      ],
                                    ),
                                    child: Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        })
                        .whereType<Marker>()
                        .toList();

                    return MarkerLayer(markers: markers);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
