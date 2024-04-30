import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../config.dart';

class PromptRepo {
  static Future<Uint8List?> generateImage(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.getimg.ai/v1/models?pipeline=text-to-image&family=stable-diffusion-xl'),
        headers: {
          'accept': 'application/json',
          'content-type': 'application/json',
          'authorization': bearerKey,
        },
        body: jsonEncode({
          'model': 'stable-diffusion-xl-v1-0',
          'prompt': prompt,
          'width': 1536,
          'height': 1536,
          'steps': 100,
        }),
      );

      final dynamic responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final String imageDataString = responseData['image'];
        final Uint8List imageData = base64Decode(imageDataString);
        return imageData;
      } else if (response.statusCode == 400) {
        print('Error 400: ${responseData['error']['message']}');
        return null;
      } else if (response.statusCode == 401) {
        print('Error 401: ${responseData['error']['message']}');
        return null;
      } else if (response.statusCode == 429) {
        print('Error 429: ${responseData['error']['message']}');
        return null;
      } else {
        print('Error ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}