// lib/services/imgbb_service.dart

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ImgBBService {
  static const String _apiKey = 'd0b7f222e6cc5c67fde4149e927cee96';

  static Future<String?> uploadImage(File imageFile) async {
    final Uri url = Uri.parse("https://api.imgbb.com/1/upload?key=$_apiKey");

    try {
      final bytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(bytes);

      final response = await http.post(
        url,
        body: {
          'image': base64Image,
          'name': 'profile_${DateTime.now().millisecondsSinceEpoch}',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['data']['url'];
      } else {
        print('❌ ImgBB Error: ${data['error']['message']}');
        return null;
      }
    } catch (e) {
      print('❌ Upload Exception: $e');
      return null;
    }
  }
}
