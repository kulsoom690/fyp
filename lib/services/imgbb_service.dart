import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ImgBBService {
  static const String apiKey = 'd0b7f222e6cc5c67fde4149e927cee96';

  static Future<String?> uploadImage(File imageFile) async {
    final uri = Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey');

    final base64Image = base64Encode(await imageFile.readAsBytes());

    try {
      final response = await http.post(
        uri,
        body: {
          'image': base64Image,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['url'];
      } else {
        print('❌ Upload failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Exception: $e');
      return null;
    }
  }
}
