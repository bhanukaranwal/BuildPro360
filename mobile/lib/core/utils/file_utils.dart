import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';

class FileUtils {
  static Future<bool> hasStoragePermission() async {
    final status = await Permission.storage.status;
    
    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      final result = await Permission.storage.request();
      return result.isGranted;
    }
    
    return false;
  }
  
  static Future<String> getDocumentsPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
  
  static Future<String> getTemporaryPath() async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }
  
  static Future<bool> fileExists(String filePath) async {
    final file = File(filePath);
    return await file.exists();
  }
  
  static Future<File> saveFile(String data, String fileName, {String? directory}) async {
    final path = directory ?? await getDocumentsPath();
    final file = File('$path/$fileName');
    return await file.writeAsString(data);
  }
  
  static Future<String> readFile(String filePath) async {
    final file = File(filePath);
    return await file.readAsString();
  }
  
  static Future<File> saveBytes(List<int> bytes, String fileName, {String? directory}) async {
    final path = directory ?? await getDocumentsPath();
    final file = File('$path/$fileName');
    return await file.writeAsBytes(bytes);
  }
  
  static Future<List<int>> readBytes(String filePath) async {
    final file = File(filePath);
    return await file.readAsBytes();
  }
  
  static Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  static Future<File?> downloadFile(String url, {String? directory, String? fileName}) async {
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final path = directory ?? await getDocumentsPath();
        String name = fileName ?? _generateFileName(url);
        
        final file = File('$path/$name');
        await file.writeAsBytes(response.bodyBytes);
        return file;
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  static String _generateFileName(String url) {
    final uri = Uri.parse(url);
    final path = uri.path;
    final extension = path.contains('.') ? path.split('.').last : '';
    
    final uuid = const Uuid().v4();
    final date = DateFormat('yyyyMMdd').format(DateTime.now());
    
    return '$date-$uuid${extension.isNotEmpty ? '.$extension' : ''}';
  }
  
  static String getFileExtension(String filePath) {
    if (filePath.contains('.')) {
      return filePath.split('.').last;
    }
    return '';
  }
  
  static String getFileName(String filePath) {
    if (filePath.contains('/')) {
      return filePath.split('/').last;
    }
    return filePath;
  }
  
  static String getFileNameWithoutExtension(String filePath) {
    final fileName = getFileName(filePath);
    if (fileName.contains('.')) {
      return fileName.substring(0, fileName.lastIndexOf('.'));
    }
    return fileName;
  }
  
  static String getMimeType(String filePath) {
    final mimeType = lookupMimeType(filePath);
    return mimeType ?? 'application/octet-stream';
  }
  
  static bool isImage(String filePath) {
    final mimeType = getMimeType(filePath);
    return mimeType.startsWith('image/');
  }
  
  static bool isPdf(String filePath) {
    final mimeType = getMimeType(filePath);
    return mimeType == 'application/pdf';
  }
  
  static bool isVideo(String filePath) {
    final mimeType = getMimeType(filePath);
    return mimeType.startsWith('video/');
  }
  
  static bool isAudio(String filePath) {
    final mimeType = getMimeType(filePath);
    return mimeType.startsWith('audio/');
  }
  
  static Future<int> getFileSize(String filePath) async {
    final file = File(filePath);
    return await file.length();
  }
  
  static Future<List<FileSystemEntity>> listDirectory(String dirPath) async {
    final directory = Directory(dirPath);
    return await directory.list().toList();
  }
  
  static Future<bool> createDirectory(String dirPath) async {
    try {
      final directory = Directory(dirPath);
      await directory.create(recursive: true);
      return true;
    } catch (e) {
      return false;
    }
  }
}