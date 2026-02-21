import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/qr_service.dart'; // We will create this next

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController(
    text: ' ',
  );
  
  // State variables for customization
  Color _selectedColor = Colors.black;
  final GlobalKey _qrKey = GlobalKey();

  // Preset colors for the user to choose from
  final List<Color> _colorPresets = [
    Colors.black,
    Colors.blue.shade800,
    Colors.deepPurple.shade700,
    Colors.red.shade900,
    const Color(0xFFE91E63), // DuitNow-style Pink
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Genie'),
        centerTitle: true,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // 1. Input Field
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'URL or Text',
                hintText: 'Enter link here...',
                prefixIcon: const Icon(Icons.link),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 40),

            // 2. QR Code Preview (The part we capture as an image)
            RepaintBoundary(
              key: _qrKey,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1)
                  ],
                ),
                child: QrImageView(
                  data: _controller.text,
                  version: QrVersions.auto,
                  size: 240.0,
                  gapless: false,
                  errorCorrectionLevel: QrErrorCorrectLevel.H, // Crucial for logos
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.circle,
                    color: _selectedColor,
                  ),
                  dataModuleStyle: QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.circle,
                    color: _selectedColor,
                  ),
                  embeddedImage: const AssetImage('assets/logo.png'),
                  embeddedImageStyle: const QrEmbeddedImageStyle(
                    size: Size(50, 50),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // 3. Color Picker
            const Text("Customize Color", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _colorPresets.map((color) => _buildColorButton(color)).toList(),
            ),
            const SizedBox(height: 50),

            // 4. Action Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _exportQR,
                icon: const Icon(Icons.download_rounded),
                label: const Text("Save to Gallery", style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    bool isSelected = _selectedColor == color;
    return GestureDetector(
      onTap: () => setState(() => _selectedColor = color),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.grey.shade400 : Colors.transparent,
            width: 3,
          ),
        ),
        child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
      ),
    );
  }

  Future<void> _exportQR() async {
    // Show a loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Processing image...")),
    );
    
    bool success = await QRService.saveQrToGallery(_qrKey);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? "Success! Saved to gallery." : "Failed to save image."),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }
}