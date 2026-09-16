import 'package:basic_widget/repository/upload_repository.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FileTestScreen extends StatefulWidget {
  final UploadRepository uploadRepository;

  const FileTestScreen({super.key, required this.uploadRepository});

  @override
  State<FileTestScreen> createState() => _FileTestScreenState();
}

class _FileTestScreenState extends State<FileTestScreen> {
  PlatformFile? selectedFile;
  double uploadProgress = 0;
  bool isUploading = false;
  String? uploadMessage;

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(withData: true);

    // User closed the file picker without selecting anything
    if (result == null) {
      return;
    }
    setState(() {
      uploadProgress = 0;
    });
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

  Future<void> _uploadFile() async {
    if (selectedFile == null) {
      setState(() {
        uploadMessage = "Please Select a file first";
      });
      debugPrint('Please select a file first');
      return;
    }

    final bytes = selectedFile!.bytes;

    if (bytes == null) {
      setState(() {
        uploadMessage = "File bytes are unavaliable";
      });
      debugPrint('File bytes are unavaliable');
      return;
    }
    setState(() {
      isUploading = true;
      uploadProgress = 0;
      uploadMessage = null;
    });
    try {
      debugPrint('UPLOAD STARTED');

      final response = await widget.uploadRepository.uploadFile(
        name: "Namir",
        email: "nk.namirkhan1@gmial.com",
        bytes: bytes,
        fileName: selectedFile!.name,
        onSendProgress: (sent, total) {
          if (!mounted || total <= 0) return;
          setState(() {
            uploadProgress = sent / total;
          });
        },
      );
      if (!mounted) return;

      setState(() {
        isUploading = false;
        uploadMessage = "File upload sucessfully";
      });
      debugPrint('UPLOAD SUCESS');
      debugPrint('RESPONSE: $response');
    } catch (err) {
      if (!mounted) return;

      setState(() {
        isUploading = false;
        uploadMessage = err.toString();
      });
      debugPrint('UPLOAD FAILED: $err');
    }
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
              onPressed: isUploading ? null : _uploadFile,
              child: Text(isUploading ? 'Uploading...' : 'Upload File'),
            ),

            if (isUploading) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(value: uploadProgress),
              const SizedBox(height: 8),

              Text('${(uploadProgress * 100).toStringAsFixed(0)}%'),
            ],

            if (uploadMessage != null) ...[
              const SizedBox(height: 12),
              Text(uploadMessage!),
            ],
          ],
        ),
      ),
    );
  }
}
