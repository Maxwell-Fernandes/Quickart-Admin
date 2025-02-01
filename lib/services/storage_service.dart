import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile(String filePath, String fileName) async {
    File file = File(filePath);
    try {
      await _storage.ref('uploads/$fileName').putFile(file);
      String downloadUrl =
          await _storage.ref('uploads/$fileName').getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw 'Failed to upload file: ${e.toString()}';
    }
  }

  Future<void> deleteFile(String fileName) async {
    try {
      await _storage.ref('uploads/$fileName').delete();
    } catch (e) {
      throw 'Failed to delete file: ${e.toString()}';
    }
  }
}
