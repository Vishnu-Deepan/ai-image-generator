// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:http/http.dart' as http;
// import '../../config.dart';
//
// class PromptRepo {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   Future<Uint8List?> generateImage(String prompt) async {
//     final url = Uri.parse('https://api.deepai.org/api/text2img');
//     final headers = {
//       'Content-Type': 'application/json',
//       'api-key': bearerKey,
//     };
//     final body = jsonEncode({'text': prompt});
//
//     final response = await http.post(url, headers: headers, body: body);
//     if (response.statusCode == 200) {
//       final responseData = jsonDecode(response.body);
//       final imageData = responseData['output_url'] as String;
//       savePromptData(prompt, imageData);
//       return await _fetchImage(imageData);
//     } else {
//       throw Exception('Failed to generate image: ${response.statusCode}');
//     }
//   }
//
//   static Future<Uint8List?> _fetchImage(String imageUrl) async {
//     final response = await http.get(Uri.parse(imageUrl));
//     if (response.statusCode == 200) {
//       return response.bodyBytes;
//     } else {
//       throw Exception('Failed to fetch image: ${response.statusCode}');
//     }
//   }
//
//   Future<void> savePromptData(String textInput, String imageUrl) async {
//     final user = _auth.currentUser;
//     if (user != null) {
//       await _firestore.collection('users').doc(user.uid)
//           .collection('history')
//           .add({
//         'textInput': textInput,
//         'imageUrl': imageUrl,
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//     }
//   }
// }

//
import 'dart:developer';

import 'dart:typed_data';

import 'package:ai_image_generator/user_data.dart';
import 'package:dio/dio.dart';

import '../../config.dart';

class PromptRepo {
  static Future<Uint8List?> generateImage(String prompt) async {
    try {
      String url = 'https://api.vyro.ai/v1/imagine/api/generations';

      Map<String, dynamic> headers = {
        'Authorization':
            'Bearer $apiKey'
        //replac your apiKey in config.dart
      };

      Map<String, dynamic> payload = {
        'prompt': prompt,
        'style_id': '122',
        'aspect_ratio': '1:1',
        'cfg': '5',
        'seed': '1',
        'high_res_results': '1'
      };

      FormData formData = FormData.fromMap(payload);

      Dio dio = Dio();

      dio.options =
          BaseOptions(headers: headers, responseType: ResponseType.bytes);

      final response = await dio.post(url, data: formData);

      if (response.statusCode == 200) {
        // log(response.data.runtimeType.toString());

        log(response.data.toString());

        Uint8List uint8List = Uint8List.fromList(response.data);
        saveUserData(prompt, uint8List);
        return uint8List;
      } else {
        return null;
      }
    } catch (e) {
      log(e.toString());
    }

  }
}
