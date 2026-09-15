import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FileTestScreen extends StatefulWidget {
  const FileTestScreen({super.key});

  @override
  State<FileTestScreen> createState() => _FileTestScreenState();
}

class _FileTestScreenState extends State<FileTestScreen> {
  PlatformFile? selectedFile;

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(withData: true);

    // User closed the file picker without selecting anything
    if (result == null) {
      return;
    }

    final file = result.files.single;

    setState(() {
      selectedFile = file;
    });

    // For learning/debugging
    debugPrint('FILE NAME: ${file.name}');
    debugPrint('FILE SIZE: ${file.size}');
    debugPrint('FILE EXTENSION: ${file.extension}');
    debugPrint('BYTES AVAILABLE: ${file.bytes != null}');
  }

  // Prepare file for upload

  Future<void> _prepareUpload() async {
    if (selectedFile == null) {
      debugPrint('No file selected');
      return;
    }

    final bytes = selectedFile!.bytes;

    if (bytes == null) {
      debugPrint('File bytes are unavailable');
      return;
    }

    final multipartFile = MultipartFile.fromBytes(
      bytes,
      filename: selectedFile!.name,
    );

    final formData = FormData.fromMap({
      'name': 'Namir',
      'email': 'namir@example.com',
      'file': multipartFile,
    });

    debugPrint('FORM DATA CREATED');
    debugPrint('Fields: ${formData.fields}');
    debugPrint('Files: ${formData.files}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('File Picker Test')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _pickFile,
              child: const Text('Pick File'),
            ),

            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _prepareUpload,
              child: const Text('Prepare upload'),
            ),
            const SizedBox(height: 12),

            if (selectedFile == null) const Text('No file selected'),

            if (selectedFile != null) ...[
              Text(
                'Name: ${selectedFile!.name}',
                style: const TextStyle(fontSize: 18),
              ),

              const SizedBox(height: 8),

              Text('Size: ${selectedFile!.size} bytes'),

              const SizedBox(height: 8),

              Text('Extension: ${selectedFile!.extension ?? 'Unknown'}'),

              const SizedBox(height: 8),

              Text('Bytes available: ${selectedFile!.bytes != null}'),
            ],

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _prepareUpload,
              child: const Text('Prepare Upload'),
            ),
          ],
        ),
      ),
    );
  }
}
