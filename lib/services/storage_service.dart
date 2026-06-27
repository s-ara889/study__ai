import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static final FirebaseStorage _storage =
      FirebaseStorage.instance;

  static Future<String?> uploadFile(
      File file,
      String fileName,
      ) async {
    try {
      final ref = _storage
          .ref()
          .child('uploads')
          .child(
        '${DateTime.now().millisecondsSinceEpoch}_$fileName',
      );

      await ref.putFile(file);

      return await ref.getDownloadURL();
    } catch (e) {
      print(e);
      return null;
    }
  }
}