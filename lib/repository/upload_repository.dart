import 'package:basic_widget/bloc/network/api_client.dart';
import 'package:dio/dio.dart';
import 'dart:typed_data';

class UploadRepository {
  final ApiClient apiClient;

  UploadRepository({required this.apiClient});

  Future<dynamic> uploadFile({
    required String name,
    required String email,
    required Uint8List bytes,
    required String fileName,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    final multipartFile = MultipartFile.fromBytes(bytes, filename: fileName);

    final formData = FormData.fromMap({
      'name': name,
      'email': email,
      'file': multipartFile,
    });
    final response = await apiClient.post(
      'http://localhost:3000/upload',
      formData,
      onSendProgress: onSendProgress,
    );
    return response.data;
  }
}
