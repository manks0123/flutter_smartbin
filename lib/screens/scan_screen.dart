import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/firestore_service.dart';
import '../services/mock_ai_service.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final FirestoreService service = FirestoreService();
  final ImagePicker _picker = ImagePicker();

  File? _image;        // ⭐ รูปที่ถ่าย
  String? result;      // ⭐ ผล AI

  // 📷 เปิดกล้อง
  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (photo == null) return;

    setState(() {
      _image = File(photo.path);
      result = null; // reset result
    });
  }

  // 🧠 วิเคราะห์ (mock AI)
  Future<void> _analyze() async {
    if (_image == null) return;

    final aiResult = MockAIService.predict();

    setState(() {
      result = aiResult;
    });

    await service.addScan(aiResult);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Detected: $aiResult'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Waste'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Classify Your Waste',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // 📷 Camera / Image Preview
            GestureDetector(
              onTap: _takePhoto,
              child: Container(
                height: 260,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _image == null
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.camera_alt,
                                size: 70, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Tap to take photo'),
                          ],
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          _image!,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Results',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 12),

            // ♻️ Result Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ResultCard(
                  title: 'Paper',
                  color: Colors.green,
                  active: result == 'Paper',
                ),
                _ResultCard(
                  title: 'Plastic',
                  color: Colors.blue,
                  active: result == 'Plastic',
                ),
                _ResultCard(
                  title: 'Organic',
                  color: Colors.brown,
                  active: result == 'Organic',
                ),
              ],
            ),

            const Spacer(),

            // 🔘 Analyze Button
            ElevatedButton.icon(
              onPressed: _image == null ? null : _analyze,
              icon: const Icon(Icons.psychology),
              label: const Text('Analyze Waste'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String title;
  final Color color;
  final bool active;

  const _ResultCard({
    required this.title,
    required this.color,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 95,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: active ? color.withOpacity(0.25) : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: active ? Border.all(color: color, width: 2) : null,
      ),
      child: Column(
        children: [
          Icon(Icons.recycling, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
