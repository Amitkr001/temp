import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

class AIScreen extends StatefulWidget {
  const AIScreen({Key? key}) : super(key: key);

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  String prompt = '';
  Uint8List? imageBytes;
  bool loading = false;
  String error = '';

  Future<void> generateImage() async {
    if (prompt.trim().isEmpty) {
      setState(() {
        error = 'Please enter a prompt';
      });
      return;
    }

    setState(() {
      loading = true;
      error = '';
      imageBytes = null;
    });

    try {
      final response = await http.post(
        Uri.parse('https://api-inference.huggingface.co/models/runwayml/stable-diffusion-v1-5'),
        headers: {
          'Authorization': 'Bearer YOUR_HUGGINGFACE_API_KEY',
          'Content-Type': 'application/json',
        },
        body: '{"inputs": "$prompt"}',
      );

      if (response.statusCode == 200) {
        setState(() {
          imageBytes = response.bodyBytes;
        });
      } else {
        setState(() {
          error = 'Failed to generate image';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> downloadImage() async {
    if (imageBytes == null) return;

    final status = await Permission.storage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission denied')),
      );
      return;
    }

    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/ai_image.png');
      await file.writeAsBytes(imageBytes!);

      final bool? success = await GallerySaver.saveImage(file.path);
      if (success == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image saved to gallery!')),
        );
      } else {
        throw 'GallerySaver failed';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Image Generator')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: (val) => prompt = val,
              decoration: const InputDecoration(
                hintText: 'Enter a prompt...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: loading ? null : generateImage,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Generate Image'),
            ),
            const SizedBox(height: 20),
            if (error.isNotEmpty)
              Text(error, style: const TextStyle(color: Colors.red)),
            if (imageBytes != null) ...[
              Image.memory(imageBytes!, height: 300),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: downloadImage,
                child: const Text('Download Image'),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
