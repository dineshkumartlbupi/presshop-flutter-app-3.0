import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:exif/exif.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EXIF Reader',
      home: const ExifReaderScreen(),
    );
  }
}

class ExifReaderScreen extends StatefulWidget {
  const ExifReaderScreen({super.key});

  @override
  State<ExifReaderScreen> createState() => _ExifReaderScreenState();
}

class _ExifReaderScreenState extends State<ExifReaderScreen> {
  final ImagePicker _picker = ImagePicker();
  Map<String, IfdTag> _exifData = {};
  File? _imageFile;

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    final File image = File(pickedFile.path);
    final Uint8List bytes = await image.readAsBytes();

    final Map<String, IfdTag> data = await readExifFromBytes(bytes);

    // Remove thumbnails (optional)
    data.remove('JPEGThumbnail');
    data.remove('TIFFThumbnail');

    setState(() {
      _imageFile = image;
      _exifData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter EXIF Reader')),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        child: const Icon(Icons.photo_library),
      ),
      body: _imageFile == null
          ? const Center(
              child: Text('Pick an image to read EXIF data'),
            )
          : Column(
              children: [
                Image.file(
                  _imageFile!,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                const Divider(),
                Expanded(
                  child: _exifData.isEmpty
                      ? const Center(
                          child: Text('No EXIF data found'),
                        )
                      : ListView.builder(
                          itemCount: _exifData.length,
                          itemBuilder: (context, index) {
                            final entry = _exifData.entries.elementAt(index);
                            return ListTile(
                              title: Text(entry.key),
                              subtitle: Text(entry.value.toString()),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
