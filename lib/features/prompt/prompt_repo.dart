import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../config.dart';

class PromptRepo {
  static Future<Uint8List?> generateImage(String prompt) async {
    final url = Uri.parse('https://api.deepai.org/api/text2img');
    final headers = {
      'Content-Type': 'application/json',
      'api-key': bearerKey,
    };
    final body = jsonEncode({'text': prompt});

    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final imageData = responseData['output_url'] as String;
      return await _fetchImage(imageData);
    } else {
      throw Exception('Failed to generate image: ${response.statusCode}');
    }
  }

  static Future<Uint8List?> _fetchImage(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to fetch image: ${response.statusCode}');
    }
  }
}