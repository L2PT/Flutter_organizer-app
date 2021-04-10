import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  static final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  
  static Future<void> uploadFile(dynamic file, String storagePath) async {
    try {
      if(file is File)
        await _firebaseStorage.ref(storagePath).putFile(file);
      else
        await _firebaseStorage.ref(storagePath).putData(file);
    } on FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
    }
  }
  
  static Future<void> deleteFile(String path) async {
    File file = File(path);

    try {
      await _firebaseStorage.ref('uploads/file-to-upload.png') .putFile(file);
    } on FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
    }
  }

  static Future<ListResult> listFiles(String path) async {
    ListResult result =  await _firebaseStorage.ref(path).listAll();
    // result.items.forEach((Reference ref) {
    //   print('Found file: $ref');
    // });
    //
    // result.prefixes.forEach((Reference ref) {
    //   print('Found directory: $ref');
    // });
    return result;
  }

  static Future<String> downloadURL(String path) async {
    String downloadURL = await _firebaseStorage.ref(path).getDownloadURL();
    return downloadURL;
  }
  
}
