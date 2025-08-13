import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _imagePicker = ImagePicker();

  // Upload single image
  Future<String?> uploadImage(File imageFile, String folder) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      final filePath = '$folder/$fileName';
      
      await _supabase.storage
          .from('images')
          .upload(filePath, imageFile);
      
      final imageUrl = _supabase.storage
          .from('images')
          .getPublicUrl(filePath);
      
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Upload multiple images
  Future<List<String>> uploadImages(List<File> imageFiles, String folder) async {
    final List<String> uploadedUrls = [];
    
    for (final imageFile in imageFiles) {
      final url = await uploadImage(imageFile, folder);
      if (url != null) {
        uploadedUrls.add(url);
      }
    }
    
    return uploadedUrls;
  }

  // Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }

  // Pick multiple images from gallery
  Future<List<File>> pickMultipleImagesFromGallery() async {
    try {
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      return pickedFiles.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      print('Error picking multiple images: $e');
      return [];
    }
  }

  // Pick image from camera
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from camera: $e');
      return null;
    }
  }

  // Delete image from storage
  Future<bool> deleteImage(String imageUrl) async {
    try {
      final fileName = path.basename(imageUrl);
      await _supabase.storage
          .from('images')
          .remove([fileName]);
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  // Get image size in MB
  double getImageSizeInMB(File imageFile) {
    final bytes = imageFile.lengthSync();
    return bytes / (1024 * 1024);
  }

  // Compress image if needed
  Future<File> compressImageIfNeeded(File imageFile, {double maxSizeMB = 5.0}) async {
    final currentSize = getImageSizeInMB(imageFile);
    
    if (currentSize <= maxSizeMB) {
      return imageFile;
    }
    
    // TODO: Implement image compression
    // For now, return original file
    return imageFile;
  }

  // Upload property images
  Future<List<String>> uploadPropertyImages(List<File> imageFiles, String propertyId) async {
    final folder = 'properties/$propertyId';
    return await uploadImages(imageFiles, folder);
  }

  // Upload user avatar
  Future<String?> uploadUserAvatar(File imageFile, String userId) async {
    final folder = 'avatars/$userId';
    return await uploadImage(imageFile, folder);
  }

  // Get storage usage
  Future<Map<String, dynamic>> getStorageUsage() async {
    try {
      // TODO: Implement storage usage calculation
      return {
        'used': 0,
        'total': 1000, // MB
        'percentage': 0.0,
      };
    } catch (e) {
      print('Error getting storage usage: $e');
      return {
        'used': 0,
        'total': 1000,
        'percentage': 0.0,
      };
    }
  }

  // Clean up temporary files
  Future<void> cleanupTempFiles() async {
    try {
      // TODO: Implement cleanup of temporary files
      print('Cleaning up temporary files...');
    } catch (e) {
      print('Error cleaning up temporary files: $e');
    }
  }
}