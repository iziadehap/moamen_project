import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shimmer_ai/shimmer_ai.dart';

class ImageUtils {
  /// Compresses an image to WebP format
  static Future<File> compressImage(File file) async {
    final filePath = file.absolute.path;

    // Create a target path in the same directory but with a .webp extension
    final lastDotIndex = filePath.lastIndexOf('.');
    final outPath = (lastDotIndex != -1)
        ? '${filePath.substring(0, lastDotIndex)}_compressed.webp'
        : '${filePath}_compressed.webp';

    final result = await FlutterImageCompress.compressAndGetFile(
      filePath,
      outPath,
      quality: 70,
      minWidth: 1080,
      minHeight: 1080,
      format: CompressFormat.webp,
    );

    if (result == null) return file;
    return File(result.path);
  }

  /// Uploads a photo to Supabase storage and returns the public URL
  static Future<String?> uploadPhoto({
    required SupabaseClient supabase,
    required File file,
    required String bucket,
  }) async {
    print('Uploading photo: ${file.path}');
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';

      // Upload returns the path if successful
      await supabase.storage.from(bucket).upload(fileName, file);

      final url = supabase.storage.from(bucket).getPublicUrl(fileName);
      return url;
    } catch (e) {
      print('❌ Error uploading photo: $e');
      return null;
    }
  }
}

Widget BuildImagesShimmerEffect() {
  return SizedBox().withShimmerAi(loading: true);
}
